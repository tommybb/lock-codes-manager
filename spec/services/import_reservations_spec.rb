require 'rails_helper'

describe ImportReservations do
  describe '.call' do
    context 'when import_all parameter is passed' do
      context 'when fetched reservation does not exist in db' do
        it 'saves reservation to db' do
          Delayed::Worker.delay_jobs = false
          travel_to '2017-12-24'

          reservations_payload = {
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

          reservation_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/reservations",
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
            }
          }

          guests_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/guests/12239",
            },
            "data" => {
              "type" => "guests",
              "id" => "12239",
              "attributes" => {
                "first-name" => "Tony",
                "last-name" => "Stark",
                "phone-number" => "09123111112",
                "email" => "tony@stark.dev"
              },
            }
          }

          rooms_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/rooms/199348",
            },
            "data" => {
              "type" => "rooms",
              "id" => "199348",
              "attributes" => {
                "room-number" => "101",
                "room-type-name" => "Presidential suite"
              },
            }
          }

          allow(RoomyClient).to receive(:all_reservations).and_return(reservations_payload)
          allow(RoomyClient).to receive(:reservations).and_return(reservation_payload)
          allow(RoomyClient).to receive(:rooms).and_return(rooms_payload)
          allow(RoomyClient).to receive(:guests).and_return(guests_payload)

          expect { ImportReservations.call(import_all: true) }.to change { Reservation.count }.from(0).to(1)
                                                                    .and change { Room.count }.from(0).to(1)
                                                                    .and change { Guest.count }.from(0).to(1)
          expect(RoomyClient).to have_received(:all_reservations)
          expect(RoomyClient).to have_received(:reservations).with(1234567)
          expect(RoomyClient).to have_received(:rooms).with(199348)
          expect(RoomyClient).to have_received(:guests).with(12239)

          travel_back
        end
      end

      context 'when fetched reservation already exists in db' do
        it 'already existing reservation is deleted and fetched one is saved' do
          travel_to '2017-12-24'

          reservation = create(:reservation,
                               roomy_id: 1234567,
                               checkin_date: '2018-01-01',
                               checkout_date: '2018-01-02',
                               booked_at: '2017-12-22 10:00:12')

          reservations_payload = {
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

          reservation_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/reservations",
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
            }
          }

          guests_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/guests/12239",
            },
            "data" => {
              "type" => "guests",
              "id" => "12239",
              "attributes" => {
                "first-name" => "Tony",
                "last-name" => "Stark",
                "phone-number" => "09123111112",
                "email" => "tony@stark.dev"
              },
            }
          }

          rooms_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/rooms/199348",
            },
            "data" => {
              "type" => "rooms",
              "id" => "199348",
              "attributes" => {
                "room-number" => "101",
                "room-type-name" => "Presidential suite"
              },
            }
          }

          allow(RoomyClient).to receive(:all_reservations).and_return(reservations_payload)
          allow(RoomyClient).to receive(:reservations).and_return(reservation_payload)
          allow(RoomyClient).to receive(:rooms).and_return(rooms_payload)
          allow(RoomyClient).to receive(:guests).and_return(guests_payload)

          expect { ImportReservations.call(import_all: true) }.to not_change { Reservation.count }
                                                                    .and not_change { Room.count }
                                                                    .and not_change { Guest.count }
                                                                    .and change{ Reservation.first.id }
                                                                            .from(reservation.id)
                                                                            .to(Integer)
          expect(RoomyClient).to have_received(:all_reservations)
          expect(RoomyClient).to have_received(:reservations).with(1234567)
          expect(RoomyClient).to have_received(:rooms).with(199348)
          expect(RoomyClient).to have_received(:guests).with(12239)

          travel_back
        end
      end

      context 'when fetched reservation is cancelled' do
        it 'does not save reservation to db' do
          travel_to '2017-12-24'

          reservations_payload = {
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
                           "cancelled" => true
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

          allow(RoomyClient).to receive(:all_reservations).and_return(reservations_payload)
          allow(RoomyClient).to receive(:rooms)
          allow(RoomyClient).to receive(:guests)

          expect { ImportReservations.call(import_all: true) }.to not_change { Reservation.count }
                                                                    .and not_change { Room.count }
                                                                    .and not_change { Guest.count }
          expect(RoomyClient).to have_received(:all_reservations)
          expect(RoomyClient).not_to have_received(:rooms)
          expect(RoomyClient).not_to have_received(:guests)

          travel_back
        end
      end

      context 'when fetched reservation has past checkout_date' do
        it 'does not save reservation to db' do
          travel_to '2017-12-24'

          reservations_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/reservations",
              "next" => "http://roomy.dev/api/v1/reservations?page[number]=2",
              "last" => "http://roomy.dev/api/v1/reservations?page[number]=10"
            },
            "data" => [{
                         "type" => "reservations",
                         "id" => "1234567",
                         "attributes" => {
                           "checkin-date" => "2017-11-01",
                           "checkout-date" => "2017-11-02",
                           "booked-at" => "2017-10-22 10:00:12",
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

          allow(RoomyClient).to receive(:all_reservations).and_return(reservations_payload)
          allow(RoomyClient).to receive(:rooms)
          allow(RoomyClient).to receive(:guests)

          expect { ImportReservations.call(import_all: true) }.to not_change { Reservation.count }
                                                                    .and not_change { Room.count }
                                                                    .and not_change { Guest.count }
          expect(RoomyClient).to have_received(:all_reservations)

          travel_back
        end
      end
    end

    context 'when modified_from parameter is passed' do
      it 'calls RoomyClient and saves reservations' do
        travel_to '2017-12-24'

        reservations_payload = {
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

        reservation_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/reservations",
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
          }
        }

        guests_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/guests/12239",
          },
          "data" => {
            "type" => "guests",
            "id" => "12239",
            "attributes" => {
              "first-name" => "Tony",
              "last-name" => "Stark",
              "phone-number" => "09123111112",
              "email" => "tony@stark.dev"
            },
          }
        }

        rooms_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/rooms/199348",
          },
          "data" => {
            "type" => "rooms",
            "id" => "199348",
            "attributes" => {
              "room-number" => "101",
              "room-type-name" => "Presidential suite"
            },
          }
        }

        allow(RoomyClient).to receive(:reservations_modified_from).and_return(reservations_payload)
        allow(RoomyClient).to receive(:reservations).and_return(reservation_payload)
        allow(RoomyClient).to receive(:rooms).and_return(rooms_payload)
        allow(RoomyClient).to receive(:guests).and_return(guests_payload)

        expect { ImportReservations.call(modified_from: '2017-12-22') }.to change { Reservation.count }.from(0).to(1)
                                                                             .and change { Room.count }.from(0).to(1)
                                                                             .and change { Guest.count }.from(0).to(1)
        expect(RoomyClient).to have_received(:reservations_modified_from).with('2017-12-22')
        expect(RoomyClient).to have_received(:reservations).with(1234567)
        expect(RoomyClient).to have_received(:rooms).with(199348)
        expect(RoomyClient).to have_received(:guests).with(12239)

        travel_back
      end

      context 'when fetched reservation has same attributes value as already saved one' do
        it 'does not save fetched reservation' do
          travel_to '2017-12-24'

          guest = create(:guest, roomy_id: 12239)
          room = create(:room, roomy_id: 199348)
          create(:reservation,
                 roomy_id: 1234567,
                 checkin_date: '2018-01-01',
                 checkout_date: '2018-01-02',
                 booked_at: '2017-12-22 10:00:12',
                 guest: guest,
                 room: room)

          reservations_payload = {
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

          reservation_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/reservations",
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
            }
          }

          guests_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/guests/12239",
            },
            "data" => {
              "type" => "guests",
              "id" => "12239",
              "attributes" => {
                "first-name" => "Tony",
                "last-name" => "Stark",
                "phone-number" => "09123111112",
                "email" => "tony@stark.dev"
              },
            }
          }

          rooms_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/rooms/199348",
            },
            "data" => {
              "type" => "rooms",
              "id" => "199348",
              "attributes" => {
                "room-number" => "101",
                "room-type-name" => "Presidential suite"
              },
            }
          }

          allow(RoomyClient).to receive(:reservations_modified_from).and_return(reservations_payload)
          allow(RoomyClient).to receive(:reservations).and_return(reservation_payload)
          allow(RoomyClient).to receive(:rooms).and_return(rooms_payload)
          allow(RoomyClient).to receive(:guests).and_return(guests_payload)

          expect { ImportReservations.call(modified_from: '2017-12-22') }
            .to not_change { Reservation.count }
                  .and not_change { Room.count }
                  .and not_change { Guest.count }
                  .and not_change { Reservation.first.id }
          expect(RoomyClient).to have_received(:reservations_modified_from).with('2017-12-22')
          expect(RoomyClient).to have_received(:reservations).with(1234567)
          expect(RoomyClient).to have_received(:rooms).with(199348)
          expect(RoomyClient).to have_received(:guests).with(12239)

          travel_back
        end
      end

      context 'when fetched reservation has different attributes value than already saved one' do
        it 'updates already saved reservation attributes according to fetched one' do
          travel_to '2017-12-24'

          guest = create(:guest, roomy_id: 12239)
          room = create(:room, roomy_id: 199348)
          create(:reservation,
                 roomy_id: 1234567,
                 checkin_date: '2018-01-01',
                 checkout_date: '2018-01-04',
                 booked_at: '2017-12-22 10:00:12',
                 guest: guest,
                 room: room)

          reservations_payload = {
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

          reservation_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/reservations",
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
            }
          }

          guests_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/guests/12239",
            },
            "data" => {
              "type" => "guests",
              "id" => "12239",
              "attributes" => {
                "first-name" => "Tony",
                "last-name" => "Stark",
                "phone-number" => "09123111112",
                "email" => "tony@stark.dev"
              },
            }
          }

          rooms_payload = {
            "links" => {
              "self" => "http://roomy.dev/api/v1/rooms/199348",
            },
            "data" => {
              "type" => "rooms",
              "id" => "199348",
              "attributes" => {
                "room-number" => "101",
                "room-type-name" => "Presidential suite"
              },
            }
          }

          allow(RoomyClient).to receive(:reservations_modified_from).and_return(reservations_payload)
          allow(RoomyClient).to receive(:reservations).and_return(reservation_payload)
          allow(RoomyClient).to receive(:rooms).and_return(rooms_payload)
          allow(RoomyClient).to receive(:guests).and_return(guests_payload)

          expect { ImportReservations.call(modified_from: '2017-12-22') }
            .to not_change { Reservation.count }
                  .and not_change { Room.count }
                  .and not_change { Guest.count }
                  .and not_change { Reservation.first.id }
          expect(Reservation.last).to have_attributes(roomy_id: 1234567,
                                                      checkin_date: '2018-01-01'.to_date,
                                                      checkout_date: '2018-01-04'.to_date,
                                                      booked_at: '2017-12-22 10:00:12'.to_datetime,
                                                      guest_id: guest.id,
                                                      room_id: room.id)
          expect(RoomyClient).to have_received(:reservations_modified_from).with('2017-12-22')
          expect(RoomyClient).to have_received(:reservations).with(1234567)
          expect(RoomyClient).to have_received(:rooms).with(199348)
          expect(RoomyClient).to have_received(:guests).with(12239)

          travel_back
        end
      end
    end

    context 'when reservation parameter is passed' do
      it 'calls RoomyClient and saves reservation' do
        travel_to '2017-12-24'

        reservation_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/reservations",
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
                     }
        }

        guests_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/guests/12239",
          },
          "data" => {
            "type" => "guests",
            "id" => "12239",
            "attributes" => {
              "first-name" => "Tony",
              "last-name" => "Stark",
              "phone-number" => "09123111112",
              "email" => "tony@stark.dev"
            },
          }
        }

        rooms_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/rooms/199348",
          },
          "data" => {
            "type" => "rooms",
            "id" => "199348",
            "attributes" => {
              "room-number" => "101",
              "room-type-name" => "Presidential suite"
            },
          }
        }

        allow(RoomyClient).to receive(:reservations).and_return(reservation_payload)
        allow(RoomyClient).to receive(:rooms).and_return(rooms_payload)
        allow(RoomyClient).to receive(:guests).and_return(guests_payload)

        expect { ImportReservations.call(reservation: 1234567) }.to change { Reservation.count }.from(0).to(1)
                                                                      .and change { Room.count }.from(0).to(1)
                                                                      .and change { Guest.count }.from(0).to(1)
        expect(RoomyClient).to have_received(:reservations).with(1234567)
        expect(RoomyClient).to have_received(:rooms).with(199348)
        expect(RoomyClient).to have_received(:guests).with(12239)

        travel_back
      end

      it 'enqueues job responsible for setting and sending room lock pin code at 30 minutes before checkin time' do
        travel_to '2017-12-24'

        reservation_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/reservations",
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
          }
        }

        guests_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/guests/12239",
          },
          "data" => {
            "type" => "guests",
            "id" => "12239",
            "attributes" => {
              "first-name" => "Tony",
              "last-name" => "Stark",
              "phone-number" => "09123111112",
              "email" => "tony@stark.dev"
            },
          }
        }

        rooms_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/rooms/199348",
          },
          "data" => {
            "type" => "rooms",
            "id" => "199348",
            "attributes" => {
              "room-number" => "101",
              "room-type-name" => "Presidential suite"
            },
          }
        }

        stub_env('PIN_CODE_SEND_BEFORE_CHECKIN_TIME', '30')
        stub_env('PIN_CODE_RESET_AFTER_CHECKOUT_TIME', '15')
        stub_env('ROOM_CHECKIN_HOUR', '15')
        stub_env('ROOM_CHECKOUT_HOUR', '10')

        allow(RoomyClient).to receive(:reservations).and_return(reservation_payload)
        allow(RoomyClient).to receive(:rooms).and_return(rooms_payload)
        allow(RoomyClient).to receive(:guests).and_return(guests_payload)
        allow(Delayed::Job).to receive(:enqueue).and_call_original

        expect { ImportReservations.call(reservation: 1234567) }.to change { Reservation.count }.from(0).to(1)
        expect(Delayed::Job).to have_received(:enqueue)
                                  .with(
                                    SetPinCodeAndSendNotificationJob.new(Reservation.first.id),
                                    run_at: '2018-01-01'.to_time + 15.hours - 30.minutes
                                  )

        travel_back
      end

      it 'enqueues job responsible for resetting room lock pin code at 15 minutes after checkout time' do
        travel_to '2017-12-24'

        reservation_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/reservations",
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
          }
        }

        guests_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/guests/12239",
          },
          "data" => {
            "type" => "guests",
            "id" => "12239",
            "attributes" => {
              "first-name" => "Tony",
              "last-name" => "Stark",
              "phone-number" => "09123111112",
              "email" => "tony@stark.dev"
            },
          }
        }

        rooms_payload = {
          "links" => {
            "self" => "http://roomy.dev/api/v1/rooms/199348",
          },
          "data" => {
            "type" => "rooms",
            "id" => "199348",
            "attributes" => {
              "room-number" => "101",
              "room-type-name" => "Presidential suite"
            },
          }
        }

        stub_env('PIN_CODE_SEND_BEFORE_CHECKIN_TIME', '30')
        stub_env('PIN_CODE_RESET_AFTER_CHECKOUT_TIME', '15')
        stub_env('ROOM_CHECKIN_HOUR', '15')
        stub_env('ROOM_CHECKOUT_HOUR', '10')

        allow(RoomyClient).to receive(:reservations).and_return(reservation_payload)
        allow(RoomyClient).to receive(:rooms).and_return(rooms_payload)
        allow(RoomyClient).to receive(:guests).and_return(guests_payload)
        allow(Delayed::Job).to receive(:enqueue).and_call_original

        expect { ImportReservations.call(reservation: 1234567) }.to change { Reservation.count }.from(0).to(1)
        expect(Delayed::Job).to have_received(:enqueue)
                                  .with(
                                    ResetPinCodeJob.new(Reservation.first.id),
                                    run_at: '2018-01-02'.to_time + 10.hours + 15.minutes
                                  )
        travel_back
      end
    end
  end
end
Delayed::Worker.delay_jobs = true
