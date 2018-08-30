require 'rails_helper'

describe ReservationsController do
  describe '#index' do
    it 'index template is rendered' do
      user = create(:user)

      sign_in(user)

      get :index

      expect(response).to render_template(:index)
    end
  end

  describe '#create_or_update' do
    context 'when received status is "created"' do
      it 'imports new reservation' do
        allow(ImportReservations).to receive(:call)

        put :create_or_update, params: { reservation_id: '1234', status: 'created' }

        expect(ImportReservations).to have_received(:call).with(reservation: '1234')
      end
    end

    context 'when received status is "cancelled"' do
      it 'calls CancelReservation service' do
        allow(CancelReservation).to receive(:call)

        put :create_or_update, params: { reservation_id: '1234', status: 'cancelled' }

        expect(CancelReservation).to have_received(:call).with('1234')
      end
    end
  end
end
