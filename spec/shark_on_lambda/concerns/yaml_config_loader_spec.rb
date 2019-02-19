# frozen_string_literal: true

RSpec.describe SharkOnLambda::Concerns::YamlConfigLoader do
  let(:class_with_mixin) do
    Class.new do
      include SharkOnLambda::Concerns::YamlConfigLoader
    end
  end

  subject { class_with_mixin.new }

  describe '#load_yaml_files' do
    let(:stage) { :stage }
    let(:fallback) { :default }
    let(:config_files) { %w[config.yml config.local.yml] }
    let(:config_paths) do
      config_dir = File.expand_path('../../fixtures', __dir__)
      config_files.map { |config_file| File.join(config_dir, config_file) }
    end

    subject do
      instance = class_with_mixin.new
      instance.load_yaml_files(stage: stage,
                               fallback: fallback,
                               paths: config_paths)
    end

    it 'loads all files in the given order' do
      config_paths.each do |config_path|
        expect(YAML).to receive(:load_file).with(config_path).once
      end
      subject
    end

    it "skips files that don't exist" do
      non_existing_path = 'does-not-exist'

      config_paths.each do |config_path|
        expect(YAML).to receive(:load_file).with(config_path).once
      end
      expect(YAML).to_not receive(:load_file).with(non_existing_path)

      config_paths << non_existing_path
      subject
    end

    it 'returns a hash with indifferent access' do
      expect(subject).to be_a(HashWithIndifferentAccess)
    end

    context 'with configuration for the requested stage' do
      let(:config_files) { %w[config.yml] }
      let(:stage) { :staging }

      it 'loads the configuration for the requested stage' do
        expectation = {
          host: 'staging.example.com',
          port: 443
        }.with_indifferent_access
        expect(subject).to eq(expectation)
      end
    end

    context 'without configuration for the requested stage' do
      let(:config_files) { %w[config.yml] }

      it 'loads the configuration for the fallback stage' do
        expectation = {
          host: 'apigateway.aws.com',
          port: 443
        }.with_indifferent_access
        expect(subject).to eq(expectation)
      end
    end

    context 'with multiple configuration files' do
      let(:stage) { :development }

      it 'merges the configuration the same order they were loaded' do
        expectation = {
          host: 'localhost',
          port: 8080,
          credentials: {
            username: 'test',
            password: 'secret-password'
          }
        }.with_indifferent_access
        expect(subject).to eq(expectation)
      end
    end
  end
end
