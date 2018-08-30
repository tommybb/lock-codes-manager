class RoomyClient
  HOST_URL = 'roomy.dev'

  def self.all_reservations
    data_request('/api/v1/reservations')
  end

  def self.reservations(id)
    data_request("/api/v1/reservations/#{id}")
  end

  def self.reservations_modified_from(date)
    data_request("/api/v1/reservations", modifiedFrom: date)
  end

  def self.rooms(id)
    data_request("/api/v1/rooms/#{id}")
  end

  def self.guests(id)
    data_request("/api/v1/guests/#{id}")
  end

  def self.data_request(path, query_attributes = {})
    uri = URI::HTTP.build(
      host: HOST_URL,
      path: path,
      query: {
        api_key: ENV.fetch('ROOMY_API_KEY')
      }.merge(query_attributes).to_query
    )

    response = HTTParty.get(uri)
    response.code == 200 ? response.response.body : { error: response.code }
  end
end
