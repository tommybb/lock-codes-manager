class SetRoomPinCode
  def initialize(reservation_id)
    @reservation = Reservation.find(reservation_id)
    @lock_uuid = reservation.room.lock_uuid
  end

  def self.call(reservation_id)
    new(reservation_id).call
  end

  def call
    return if lock_uuid.nil?

    new_pin_code && reservation.update(room_lock_pin_code: new_pin_code)
  end

  private

  def new_pin_code
    @new_pin_code ||= RemoteLockeyClient.refresh(lock_uuid)['pin']
  end

  attr_reader :reservation, :lock_uuid
end
