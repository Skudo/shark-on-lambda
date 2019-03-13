# frozen_string_literal: true

require 'shark-on-lambda'

class DockerContainer
  attr_reader :project_dir, :tag
  attr_accessor :params, :commands

  def initialize(project_dir:, tag: 'latest')
    @project_dir = project_dir
    @tag = tag
    @params = default_params
    @commands = default_commands
  end

  def build
    sh("cd #{project_dir} && docker build . -t #{name}")
  end

  def exist?
    system("docker image inspect #{name} &> /dev/null")
  end

  def mount_dir
    File.join('/src', project_name)
  end

  def name
    "#{project_name}-builder:#{tag}"
  end

  def remove
    sh("docker image rm #{name}")
  end

  def run
    arguments = params.join(' ')
    command = commands.join(' && ')

    sh(%(docker run #{arguments} #{name} /bin/bash -c "#{command}"))
  end

  def working_dir
    File.join('/tmp', project_name)
  end

  protected

  def default_commands
    [
      "cp -a #{mount_dir} #{working_dir}",
      "cd #{working_dir}"
    ]
  end

  def default_params
    [
      '--rm',
      "-v #{project_dir}:#{mount_dir}"
    ]
  end

  def project_name
    File.basename(project_dir)
  end

  def sh(command)
    puts command
    system(command)
  end
end

def build_stage(stage)
  container = DockerContainer.new(project_dir: SharkOnLambda.root)
  Rake::Task['docker:build'].invoke unless container.exist?

  container.commands += build_commands(container, stage: stage)
  container.run
end

def deploy_stage(stage)
  deploy_command = deploy_commands(stage: stage).join(' && ')
  sh(deploy_command)
end

def remove_stage(stage)
  sh("sls remove -v -s #{stage}")
end

namespace :docker do
  container = DockerContainer.new(project_dir: SharkOnLambda.root)

  desc 'Build the Docker container required for... building.'
  task :build do
    container.build
  end

  desc 'Remove the Docker container required for building.'
  task :remove do
    container.remove
  end
end

%i[integration staging production].each do |stage|
  namespace :build do
    desc "Build this service for the '#{stage}' stage."
    task stage => [:clean] do
      build_stage(stage)
    end
  end

  namespace :deploy do
    desc "Deploy this service to the '#{stage}' stage."
    task stage => ["build:#{stage}"] do
      deploy_stage(stage)
    end
  end

  namespace :remove do
    desc "Remove this service from the '#{stage}' stage."
    task stage do
      remove_stage(stage)
    end
  end
end

desc 'Build this service for STAGE.'
task :build, [:stage] => [:clean] do |_, args|
  build_stage(args.stage)
end

desc 'Remove package build directory.'
task :clean do
  package_dir = SharkOnLambda.root.join('pkg')
  FileUtils.rm_rf(package_dir)
end

desc 'Deploy this service to STAGE.'
task :deploy, [:stage] => [:build] do |_, args|
  deploy_stage(args.stage)
end

desc 'Remove this service from STAGE.'
task :remove, [:stage] do |_, args|
  remove_stage(args.stage)
end
