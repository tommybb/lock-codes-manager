class PinCodeMailer < ActionMailer::Base
  default from: ENV.fetch('DEFAULT_MAIL_FROM_ADDRESS')

  def new_pin_code(reservation)
    @guest = reservation.guest
    @pin_code = reservation.room_lock_pin_code
    mail(to: @guest.email, subject: 'Room access information')
  end
end
