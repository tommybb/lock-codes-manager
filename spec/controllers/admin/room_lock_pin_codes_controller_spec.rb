require 'rails_helper'

describe Admin::RoomLockPinCodesController do
  describe '#resend' do
    it 'calls SendRoomPinCode service' do
      allow(SendRoomPinCode).to receive(:call)
      admin = create(:user, admin: true)

      sign_in(admin)

      put :resend, params: { id: 1234 }

      expect(SendRoomPinCode).to have_received(:call).with(1234)
    end
  end

  describe '#reset' do
    it 'calls SetRoomPinCode service' do
      allow(SetRoomPinCode).to receive(:call)
      admin = create(:user, admin: true)

      sign_in(admin)

      put :reset, params: { id: 1234 }

      expect(SetRoomPinCode).to have_received(:call).with(1234)
    end
  end
end
