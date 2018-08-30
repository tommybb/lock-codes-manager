class SendRoomPinCode
  TWILIO_MOBILE_NUMBER = ENV.fetch('TWILIO_MOBILE_NUMBER')
  TWILIO_ACCOUNT_SID = ENV.fetch('TWILIO_ACCOUNT_SID')
  TWILIO_AUTH_TOKEN = ENV.fetch('TWILIO_AUTH_TOKEN')

  def initialize(reservation_id)
    @reservation = Reservation.find(reservation_id)
    @twilio_client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
    @receiver_phone_number = reservation.guest.phone_number
  end

  def self.call(reservation_id)
    new(reservation_id).call
  end

  def call
    send_email_to_guest
    send_sms_to_guest
  end

  private

  def send_email_to_guest
    PinCodeMailer.new_pin_code(reservation).deliver
  end

  def send_sms_to_guest
    return if invalid_receiver_phone_number?

    twilio_client.messages.create(from: TWILIO_MOBILE_NUMBER, to: receiver_phone_number, body: sms_body)
  end

  def invalid_receiver_phone_number?
    @receiver_phone_number.phony_formatted(strict: true).nil?
  end

  def sms_body
    "Hi #{reservation.guest.first_name}. You can access your room with #{reservation.room_lock_pin_code} code. Enjoy!"
  end

  attr_reader :twilio_client, :reservation, :receiver_phone_number
end
