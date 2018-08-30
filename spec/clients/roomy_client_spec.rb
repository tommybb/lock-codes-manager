require 'rails_helper'

describe RoomyClient do
  describe '.all_reservations' do
    context 'when proper API key is provided' do
      it 'returns list of reservations' do
        body = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/reservations",
            "next" => "http://roomy.dev/api/v1/reservations?page[number]=2",
            "last" => "http://roomy.dev/api/v1/reservations?page[number]=10"
          },
          "data" => [{
            "type" => "reservations",
            "id" => "1234567",
            "attributes" => {
              "checkin-date" => "2018-01-01",
              "checkout-date" => "2018-01-02",
              "booked-at" => "2017-12-22 10:00:12",
              "cancelled" => false
            },
            "relationships" => {
              "guest" => {
                "data" => { "type" => "guests", "id" => "12239" }
              },
              "room" => {
                "data" => { "type" => "rooms", "id" => "199348" }
              },
            },
            "links" => {
              "self" => "http://roomy.dev/api/v1/reservations/1234567",
            }
          }],
        }
        stub_env('ROOMY_API_KEY', '123456789')
        stub_request(:get, 'http://roomy.dev/api/v1/reservations?api_key=123456789').to_return(body: body.to_json)

        expect(JSON.parse(RoomyClient.all_reservations)).to eq(body)
      end
    end

    context 'when improper API key is provided' do
      it 'returns Unauthorized error' do
        stub_env('ROOMY_API_KEY', 'invalid_key')
        stub_request(:get, 'http://roomy.dev/api/v1/reservations?api_key=invalid_key')
          .to_return(status: [401, 'Unauthorized'])

        expect(RoomyClient.all_reservations).to eq(error: 401)
      end
    end
  end

  describe '.reservations_modified_from' do
    context 'when proper API key is provided' do
      it 'returns list of reservations' do
        body = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/reservations",
            "next" => "http://roomy.dev/api/v1/reservations?page[number]=2",
            "last" => "http://roomy.dev/api/v1/reservations?page[number]=10"
          },
          "data" => [{
                       "type" => "reservations",
                       "id" => "1234567",
                       "attributes" => {
                         "checkin-date" => "2018-01-01",
                         "checkout-date" => "2018-01-02",
                         "booked-at" => "2017-12-22 10:00:12",
                         "cancelled" => false
                       },
                       "relationships" => {
                         "guest" => {
                           "data" => { "type" => "guests", "id" => "12239" }
                         },
                         "room" => {
                           "data" => { "type" => "rooms", "id" => "199348" }
                         },
                       },
                       "links" => {
                         "self" => "http://roomy.dev/api/v1/reservations/1234567",
                       }
                     }],
        }
        stub_env('ROOMY_API_KEY', '123456789')
        stub_request(:get, 'http://roomy.dev/api/v1/reservations?api_key=123456789&modifiedFrom=2017-12-01')
          .to_return(body: body.to_json)

        expect(JSON.parse(RoomyClient.reservations_modified_from('2017-12-01'))).to eq(body)
      end
    end

    context 'when improper API key is provided' do
      it 'returns Unauthorized error' do
        stub_env('ROOMY_API_KEY', 'invalid_key')
        stub_request(:get, 'http://roomy.dev/api/v1/reservations?api_key=invalid_key&modifiedFrom=2017-12-01')
          .to_return(status: [401, 'Unauthorized'])

        expect(RoomyClient.reservations_modified_from('2017-12-01')).to eq(error: 401)
      end
    end
  end

  describe '.reservations' do
    context 'when proper API key is provided' do
      it 'returns reservation with given id' do
        body = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/reservations/1234567",
          },
          "data" => {
                      "type" => "reservations",
                      "id" => "1234567",
                      "attributes" => {
                        "checkin-date" => "2018-01-01",
                        "checkout-date" => "2018-01-02",
                        "booked-at" => "2017-12-22 10:00:12",
                        "cancelled" => false
                      },
                      "relationships" => {
                        "guest" => {
                          "data" => { "type" => "guests", "id" => "12239" }
                        },
                        "room" => {
                          "data" => { "type" => "rooms", "id" => "199348" }
                        },
                      },
                    },
        }
        stub_env('ROOMY_API_KEY', '123456789')
        stub_request(:get, 'http://roomy.dev/api/v1/reservations/1234567?api_key=123456789').to_return(body: body.to_json)

        expect(JSON.parse(RoomyClient.reservations(1234567))).to eq(body)
      end
    end

    context 'when improper API key is provided' do
      it 'returns Unauthorized error' do
        stub_env('ROOMY_API_KEY', 'invalid_key')
        stub_request(:get, 'http://roomy.dev/api/v1/reservations/1234567?api_key=invalid_key')
          .to_return(status: [401, 'Unauthorized'])

        expect(RoomyClient.reservations(1234567)).to eq(error: 401)
      end
    end
  end

  describe '.guests' do
    context 'when proper API key is provided' do
      it 'returns guest with given id' do
        body = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/guests/12239",
          },
          "data" => {
            "type" => "guests",
            "id" => "12239",
            "attributes" => {
              "first-name" => "Tony",
              "last_name" => "Stark",
              "phone-number" => "09123111112",
              "email" => "tony@stark.dev"
            },
          }
        }
        stub_env('ROOMY_API_KEY', '123456789')
        stub_request(:get, 'http://roomy.dev/api/v1/guests/12239?api_key=123456789').to_return(body: body.to_json)

        expect(JSON.parse(RoomyClient.guests(12239))).to eq(body)
      end
    end

    context 'when improper API key is provided' do
      it 'returns Unauthorized error' do
        stub_env('ROOMY_API_KEY', 'invalid_key')
        stub_request(:get, 'http://roomy.dev/api/v1/guests/12239?api_key=invalid_key')
          .to_return(status: [401, 'Unauthorized'])

        expect(RoomyClient.guests(12239)).to eq(error: 401)
      end
    end
  end

  describe '.rooms' do
    context 'when proper API key is provided' do
      it 'returns room with given id' do
        body = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/rooms/199348",
          },
          "data" => {
            "type" => "rooms",
            "id" => "199348",
            "attributes" => {
              "first-name" => "Tony",
              "last_name" => "Stark",
              "room-number" => "101",
              "room-type-name" => "Presidential suite"
            },
          }
        }
        stub_env('ROOMY_API_KEY', '123456789')
        stub_request(:get, 'http://roomy.dev/api/v1/rooms/199348?api_key=123456789').to_return(body: body.to_json)

        expect(JSON.parse(RoomyClient.rooms(199348))).to eq(body)
      end
    end

    context 'when improper API key is provided' do
      it 'returns Unauthorized error' do
        stub_env('ROOMY_API_KEY', 'invalid_key')
        stub_request(:get, 'http://roomy.dev/api/v1/rooms/199348?api_key=invalid_key')
          .to_return(status: [401, 'Unauthorized'])

        expect(RoomyClient.rooms(199348)).to eq(error: 401)
      end
    end
  end
end
