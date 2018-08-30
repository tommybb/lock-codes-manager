class RemoteLockeyClient
  HOST_URL = 'remotelockey.dev'

  def self.refresh(uuid)
    uri = URI::HTTP.build(
      host: HOST_URL,
      path: "/locks/#{uuid}/refresh",
      query: {
        x_api_key: ENV.fetch('REMOTE_LOCKEY_API_KEY')
      }.to_query
    )

    response = HTTParty.get(uri)
    response.code == 200 ? JSON.parse(response.response.body) : { error: response.code }
  end
end
