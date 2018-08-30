require 'rails_helper'

describe RemoteLockeyClient do
  describe '.refresh' do
    context 'when proper API key is provided' do
      context 'when provided uuid belongs to the API key' do
        it 'returns pin code' do
          stub_env('REMOTE_LOCKEY_API_KEY', '123456789')
          stub_request(:get, 'http://remotelockey.dev/locks/d1105114-e91a-4e01-aaa5-cb8101114089/refresh?x_api_key=123456789')
            .to_return(body: { pin: 1234 }.to_json)

          expect(RemoteLockeyClient.refresh('d1105114-e91a-4e01-aaa5-cb8101114089')).to eq({ 'pin' => 1234 })
        end
      end

      context 'when provided uuid does not belong to the API key' do
        it 'returns pin code' do
          stub_env('REMOTE_LOCKEY_API_KEY', '123456789')
          stub_request(:get, 'http://remotelockey.dev/locks/xxxxxx-e91a-4e01-aaa5-xxxxxx/refresh?x_api_key=123456789')
            .to_return(status: [403, 'Forbidden'])

          expect(RemoteLockeyClient.refresh('xxxxxx-e91a-4e01-aaa5-xxxxxx')).to eq({ error: 403 })
        end
      end
    end

    context 'when improper API key is provided' do
      it 'returns Unauthorized error' do
        stub_env('REMOTE_LOCKEY_API_KEY', 'invalid_key')
        stub_request(:get, 'http://remotelockey.dev/locks/d1105114-e91a-4e01-aaa5-cb8101114089/refresh?x_api_key=invalid_key')
          .to_return(status: [401, 'Unauthorized'])

        expect(RemoteLockeyClient.refresh('d1105114-e91a-4e01-aaa5-cb8101114089')).to eq(error: 401)
      end
    end
  end
end
