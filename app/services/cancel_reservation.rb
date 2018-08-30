class CancelReservation
  def initialize(reservation_roomy_id)
    @reservation_id = Reservation.find_by(roomy_id: reservation_roomy_id).id
  end

  def self.call(reservation_roomy_id)
    new(reservation_roomy_id).call
  end

  def call
    cancel_reservation
    reset_room_pin_code
    destroy_all_relevant_jobs
  end

  private

  def cancel_reservation
    Reservation.find(reservation_id).update(cancelled: true)
  end

  def reset_room_pin_code
    SetRoomPinCode.call(reservation_id)
  end

  def destroy_all_relevant_jobs
    Delayed::Job.where('handler LIKE ?', "%reservation_id: #{reservation_id}\n").destroy_all
  end

  attr_reader :reservation_id
end
