require 'rails_helper'

describe ResetPinCodeJob, type: :job do
  it 'calls service responsible for setting pin code' do
    allow(SetRoomPinCode).to receive(:call)

    ResetPinCodeJob.new(1).perform

    expect(SetRoomPinCode).to have_received(:call).with(1)
  end
end
