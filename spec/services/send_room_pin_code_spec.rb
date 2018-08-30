require 'rails_helper'

describe SendRoomPinCode do
  describe '.call' do
    it 'sends sms with pin code to theguest' do
      stub_env('TWILIO_MOBILE_NUMBER', '+15005550006')
      twilio_messages = double(:twilio_messages, create: nil)
      twilio_client = double(:twilio_client, messages: twilio_messages)
      allow(Twilio::REST::Client).to receive(:new).and_return twilio_client

      guest = create(:guest, first_name: 'John', phone_number: '+48604633878')
      room = create(:room, lock_uuid: 'd1105114-e91a-4e01-aaa5-cb8101114089')
      reservation = create(:reservation, room: room, guest: guest, room_lock_pin_code: 1234)

      SendRoomPinCode.call(reservation.id)

      expect(twilio_messages)
        .to have_received(:create)
              .with({from: '+15005550006',
                     to: '+48604633878',
                     body: ('Hi John. You can access your room with 1234 code. Enjoy!')
                    })
    end

    it 'sends email with pin code to the guest' do
      stub_env('TWILIO_MOBILE_NUMBER', '+15005550006')
      twilio_messages = double(:twilio_messages, create: nil)
      twilio_client = double(:twilio_client, messages: twilio_messages)
      allow(Twilio::REST::Client).to receive(:new).and_return twilio_client

      guest = create(:guest, first_name: 'John', email: 'john_doe@gmail.com', phone_number: '+48604633878')
      room = create(:room, lock_uuid: 'd1105114-e91a-4e01-aaa5-cb8101114089')
      reservation = create(:reservation, room: room, guest: guest, room_lock_pin_code: 1234)

      expect { SendRoomPinCode.call(reservation.id) }.to change { ActionMailer::Base.deliveries.count }.by 1

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include('john_doe@gmail.com')
      expect(email.subject).to eq('Room access information')
      expect(email.body.to_s).to eq("Hi John\nYou can access your room with 1234 code.\n\nEnjoy!\n")
    end
  end
end
