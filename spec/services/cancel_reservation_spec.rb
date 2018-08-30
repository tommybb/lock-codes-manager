require 'rails_helper'

describe CancelReservation do
  describe '.call' do
    it 'changes status of reservation to cancelled' do
      stub_env('REMOTE_LOCKEY_API_KEY', 'k8dg9s')
      stub_request(:get, "http://remotelockey.dev/locks/55298041-419d-41ea-ada3-242161f3a395/refresh?x_api_key=k8dg9s").
        to_return(status: 200, body: { pin: 3333 }.to_json, headers: {})

      room = create(:room, lock_uuid: '55298041-419d-41ea-ada3-242161f3a395')
      reservation = create(:reservation, roomy_id: 1234, room: room, cancelled: false)

      expect { CancelReservation.call(1234) }.to change { reservation.reload.cancelled }.from(false).to(true)
    end

    it 'calls SetRoomPinCode service' do
      reservation = create(:reservation, roomy_id: 1234, cancelled: false)
      allow(SetRoomPinCode).to receive(:call)

      CancelReservation.call(1234)

      expect(SetRoomPinCode).to have_received(:call).with(reservation.id)
    end

    it 'destroys all jobs for cancelled reservation' do
      stub_env('REMOTE_LOCKEY_API_KEY', 'k8dg9s')
      stub_request(:get, "http://remotelockey.dev/locks/55298041-419d-41ea-ada3-242161f3a395/refresh?x_api_key=k8dg9s").
        to_return(status: 200, body: { pin: 3333 }.to_json, headers: {})

      room = create(:room, lock_uuid: '55298041-419d-41ea-ada3-242161f3a395')
      reservation = create(:reservation, roomy_id: 1234, room: room, cancelled: false)

      Delayed::Job.enqueue ResetPinCodeJob.new(reservation.id), locked_at: Time.current
      Delayed::Job.enqueue SetPinCodeAndSendNotificationJob.new(reservation.id), locked_at: Time.current

      expect { CancelReservation.call(1234) }.to change { Delayed::Job.count }.by(-2)
    end
  end
end
