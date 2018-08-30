class ImportReservations
  PIN_CODE_SEND_BEFORE_CHECKIN_TIME = ENV.fetch('PIN_CODE_SEND_BEFORE_CHECKIN_TIME').to_i.minutes
  PIN_CODE_RESET_AFTER_CHECKOUT_TIME = ENV.fetch('PIN_CODE_RESET_AFTER_CHECKOUT_TIME').to_i.minutes
  ROOM_CHECKIN_HOUR = ENV.fetch('ROOM_CHECKIN_HOUR').to_i.hours
  ROOM_CHECKOUT_HOUR = ENV.fetch('ROOM_CHECKOUT_HOUR').to_i.hours

  def initialize(action)
    @action = action
    @action_type = action.keys.first
  end

  def self.call(action)
    new(action).call
  end

  def call
    ActiveRecord::Base.transaction do
      delete_existing_reservations if action_type == :import_all
      import_associated_rooms
      import_associated_guests
      import_reservations
    end
  end
  handle_asynchronously :call

  private

  def delete_existing_reservations
    Reservation.destroy_all
    Room.destroy_all
    Guest.destroy_all
  end

  def import_associated_rooms
    rooms_ids = reservations_data.map { |reservation| reservation['relationships']['room']['data']['id'].to_i }
    rooms_ids.each do |room_id|
      create_or_update_room(room_id)
    end
  end

  def import_associated_guests
    guests_ids = reservations_data.map { |reservation| reservation['relationships']['guest']['data']['id'].to_i }
    guests_ids.each do |guest_id|
      create_or_update_guest(guest_id)
    end
  end

  def import_reservations
    reservations_ids = reservations_data.map { |reservation| reservation['id'].to_i }
    reservations_ids.each do |reservation_id|
      create_or_update_reservation(reservation_id)
    end
  end

  def reservations_data
    @reservations_data ||= fetch_and_delete_irrelevant_data
  end


  def fetch_and_delete_irrelevant_data
    data = case action_type
           when :import_all
             RoomyClient.all_reservations['data']
           when :modified_from
             RoomyClient.reservations_modified_from(action[:modified_from])['data']
           when :reservation
             return [RoomyClient.reservations(action[:reservation])['data']]
           end
    data.delete_if { |reservation| irrelevant_reservation?(reservation) }
  end

  def irrelevant_reservation?(reservation)
    reservation['attributes']['cancelled'] || Date.parse(reservation['attributes']['checkout-date']) < Date.current
  end

  def create_or_update_room(room_id)
    room_data = RoomyClient.rooms(room_id)['data']

    params = {
      number: room_data['attributes']['room-number'].to_i
    }

    room = Room.find_or_initialize_by(roomy_id: room_id)

    if room.new_record? || has_object_different_params?(room, params)
      room.attributes = params
      room.save!
    end
  end

  def create_or_update_guest(guest_id)
    guest_data = RoomyClient.guests(guest_id)['data']

    params = {
      first_name:  guest_data['attributes']['first-name'],
      last_name:  guest_data['attributes']['last-name'],
      phone_number: guest_data['attributes']['phone-number'],
      email: guest_data['attributes']['email']
    }

    guest = Guest.find_or_initialize_by(roomy_id: guest_id)

    if guest.new_record? || has_object_different_params?(guest, params)
      guest.attributes = params
      guest.save!
    end
  end

  def create_or_update_reservation(reservation_id)
    reservation_data = if action_type == :reservation
                         reservations_data.first
                       else
                         RoomyClient.reservations(reservation_id)['data']
                       end

    params = {
      guest_id: Guest.find_by(reservation_data['relationships']['guest']['data']['id']).id,
      room_id: Room.find_by(reservation_data['relationships']['room']['data']['id']).id,
      checkin_date: reservation_data['attributes']['checkin-date'].to_date,
      checkout_date: reservation_data['attributes']['checkout-date'].to_date,
      booked_at: reservation_data['attributes']['booked-at'].to_datetime,
      cancelled: reservation_data['attributes']['cancelled']
    }

    reservation = Reservation.find_or_initialize_by(roomy_id: reservation_id)
    is_new_record = reservation.new_record?
    if is_new_record || has_object_different_params?(reservation, params)
      reservation.attributes = params
      reservation.save!
    end
    enqueue_pin_code_jobs(reservation) if is_new_record
  end

  def has_object_different_params?(object, params)
    object.attributes.except('id', 'created_at', 'updated_at').symbolize_keys == params
  end

  def enqueue_pin_code_jobs(reservation)
    Delayed::Job.enqueue(SetPinCodeAndSendNotificationJob.new(reservation.id), run_at: pin_code_set_time(reservation))
    Delayed::Job.enqueue(ResetPinCodeJob.new(reservation.id), run_at: pin_code_reset_time(reservation))
  end

  def pin_code_set_time(reservation)
    reservation.checkin_date.to_time + ROOM_CHECKIN_HOUR - PIN_CODE_SEND_BEFORE_CHECKIN_TIME
  end

  def pin_code_reset_time(reservation)
    reservation.checkout_date.to_time + ROOM_CHECKOUT_HOUR + PIN_CODE_RESET_AFTER_CHECKOUT_TIME
  end

  attr_reader :action, :action_type
end
