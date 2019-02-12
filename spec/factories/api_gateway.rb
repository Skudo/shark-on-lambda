# frozen_string_literal: true

FactoryBot.define do
  factory :api_gateway_context, class: OpenStruct do
  end

  factory :api_gateway_event, class: OpenStruct do
    path { '/api/v1/mailing/1234' }
    resource { '/api/v1/mailing/{id}' }
    httpMethod { 'GET' }
    headers do
      {}
    end
    multiValueHeaders do
      headers.transform_values { |value| Array(value) }
    end
    queryStringParameters do
      {
        'foo[]': 'baz'
      }
    end
    multiValueQueryStringParameters do
      {
        'foo[]': %w[bar baz]
      }
    end
    pathParameters do
      {
        id: '1234'
      }
    end
    stageVariables { nil }
    requestContext do
      {
        resourceId: nil,
        resourcePath: resource,
        httpMethod: httpMethod,
        extendedRequestId: nil,
        requestTime: nil,
        path: path,
        accountId: nil,
        protocol: 'HTTP/1.1',
        stage: 'test',
        domainPrefix: nil,
        requestTimeEpoch: Time.now.to_i * 1000,
        requestId: nil,
        identity: {
          cognitoIdentityPoolId: nil,
          accountId: nil,
          cognitoIdentityId: nil,
          caller: nil,
          sourceIp: '127.0.0.1',
          accessKey: nil,
          cognitoAuthenticationType: nil,
          cognitoAuthenticationProvider: nil,
          userArn: nil,
          userAgent: 'curl/7.54.0',
          user: nil
        },
        domainName: 'test.local',
        apiId: nil
      }
    end
    body { nil }
    isBase64Encoded { false }
  end
end
