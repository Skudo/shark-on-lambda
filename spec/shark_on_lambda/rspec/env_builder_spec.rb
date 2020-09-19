# frozen_string_literal: true

RSpec.describe SharkOnLambda::RSpec::EnvBuilder do
  let(:method) { 'GET' }
  let(:controller) { 'TestApplication::ApiGatewayController' }
  let(:action) { :index }
  let(:headers) do
    {
      'content-type' => 'application/json'
    }
  end
  let(:params) { {} }
  let(:builder_params) do
    {
      method: method,
      controller: controller,
      action: action,
      headers: headers,
      params: params
    }
  end

  describe '#build' do
    subject(:env) { SharkOnLambda::RSpec::EnvBuilder.new(builder_params).build }

    %i[delete get patch post put].each do |http_verb|
      context "for a #{http_verb.to_s.upcase} request" do
        let(:method) { http_verb }

        it { expect(env['REQUEST_METHOD']).to eq(http_verb.to_s.upcase) }
      end
    end

    context 'with a symbol as the action' do
      context 'if the action exists' do
        let(:action) { :index }

        it 'determines the request path from the routes' do
          expect(env['PATH_INFO']).to eq('/api_gateway')
        end
      end

      context 'if the action does not exist' do
        let(:action) { :does_not_exist }

        it 'raises an exception' do
          expect { env }.to raise_error(ActionController::UrlGenerationError)
        end
      end
    end

    context 'with a string as the action' do
      context 'with a query string' do
        let(:action) { '/foo/bar/1?foo=bar&baz=blubb' }

        it 'takes the action as the request path' do
          expect(env['PATH_INFO']).to eq('/foo/bar/1')
        end

        it 'sets the query string' do
          expect(env['QUERY_STRING']).to eq('foo=bar&baz=blubb')
        end
      end

      context 'without a query string' do
        let(:action) { '/foo/bar/1' }

        it 'takes the action as the request path' do
          expect(env['PATH_INFO']).to eq('/foo/bar/1')
        end

        it 'does not set the query string' do
          expect(env['QUERY_STRING']).to be_empty
        end
      end
    end

    context 'with request headers' do
      let(:headers) do
        {
          'content-length': 1234,
          'content-type': 'text/plain',
          authorization: 'Bearer asdf',
          'x-foo-bar': 'baz'
        }
      end

      it do
        expect(env['CONTENT_LENGTH']).to eq(headers[:'content-length'].to_s)
      end

      it { expect(env['CONTENT_TYPE']).to eq(headers[:'content-type']) }
      it { expect(env['HTTP_AUTHORIZATION']).to eq(headers[:authorization]) }
      it { expect(env['HTTP_X_FOO_BAR']).to eq(headers[:'x-foo-bar']) }
    end

    context 'with parameters' do
      let(:action) { '/foo?bar[]=baz&bar[]=narf&blah=blubb' }
      let(:params) do
        {
          best_programming_language: 'ruby',
          days: {
            favourite: 'Friday',
            free: %w[Saturday Sunday],
            meetings: {
              breakfast: 'Wednesday',
              planning: 'Monday',
              reviews: %w[Thursday Friday]
            }
          }
        }
      end

      context 'for a GET request' do
        it 'builds the right query string' do
          expect(env['QUERY_STRING'].split('&')).to(
            match_array(%w[bar[]=baz
                           bar[]=narf
                           best_programming_language=ruby
                           blah=blubb
                           days[favourite]=Friday
                           days[free][]=Saturday
                           days[free][]=Sunday
                           days[meetings][breakfast]=Wednesday
                           days[meetings][planning]=Monday
                           days[meetings][reviews][]=Thursday
                           days[meetings][reviews][]=Friday])
          )
        end
      end

      %i[delete patch post put].each do |http_verb|
        context "for a #{http_verb.to_s.upcase} request" do
          let(:method) { http_verb }

          it 'contains the path parameters in the query string' do
            expect(env['QUERY_STRING']).to eq('bar[]=baz&bar[]=narf&blah=blubb')
          end

          it 'contains the params in the request body' do
            body = env['rack.input'].read
            expect(body).to eq(params.to_json)
          end

          it 'sets the "Content-Type" header' do
            expect(env['CONTENT_TYPE']).to eq(headers['content-type'])
          end

          it 'sets the right "Content-Length" header' do
            expect(env['CONTENT_LENGTH']).to eq(params.to_json.bytesize.to_s)
          end
        end
      end
    end
  end
end
