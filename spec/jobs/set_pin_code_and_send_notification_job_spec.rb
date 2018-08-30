require 'rails_helper'

describe SetPinCodeAndSendNotificationJob, type: :job do
  it 'calls service responsible for setting pin code' do
    allow(SetRoomPinCode).to receive(:call)
    allow(SendRoomPinCode).to receive(:call)

    SetPinCodeAndSendNotificationJob.new(1).perform

    expect(SetRoomPinCode).to have_received(:call)
  end

  it 'calls service responsible for sending notification to guest' do
    allow(SetRoomPinCode).to receive(:call)
    allow(SendRoomPinCode).to receive(:call)

    SetPinCodeAndSendNotificationJob.new(1).perform

    expect(SendRoomPinCode).to have_received(:call)
  end
end
