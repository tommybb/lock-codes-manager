require 'rails_helper'

describe SetRoomPinCode do
  describe '.call' do
    context 'when room has uuid set' do
      it 'saves new pin code for the reservation' do
        room = create(:room, lock_uuid: 'd1105114-e91a-4e01-aaa5-cb8101114089')

        reservation = create(:reservation, room: room, room_lock_pin_code: 1111)
        allow(RemoteLockeyClient).to receive(:refresh).and_return({ "pin" => 1234 })

        expect { SetRoomPinCode.call(reservation.id) }
          .to change { reservation.reload.room_lock_pin_code }.from(1111).to(1234)
        expect(RemoteLockeyClient).to have_received(:refresh).with('d1105114-e91a-4e01-aaa5-cb8101114089')
      end
    end

    context 'when room has not uuid set' do
      it 'does not save pin code for the reservation' do
        room = create(:room, lock_uuid: nil)
        reservation = create(:reservation, room: room, room_lock_pin_code: nil)
        allow(RemoteLockeyClient).to receive(:refresh).and_return({ "pin" => 1234 })

        expect { SetRoomPinCode.call(reservation.id) }.to not_change { reservation.reload.room_lock_pin_code }
        expect(RemoteLockeyClient).not_to have_received(:refresh)
      end
    end
  end
end
