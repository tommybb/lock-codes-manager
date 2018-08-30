ResetPinCodeJob = Struct.new(:reservation_id) do
  def perform
    SetRoomPinCode.call(reservation_id)
  end
end
