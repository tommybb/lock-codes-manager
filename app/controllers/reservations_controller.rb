class ReservationsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create_or_update

  def index
    @q = Reservation.ransack(params[:q])
    @reservations = @q.result.includes(:room, :guest)
  end

  def create_or_update
    status = params[:status]
    if status == 'created'
      ImportReservations.call(reservation: reservation_roomy_id)
    elsif status == 'cancelled'
      CancelReservation.call(reservation_roomy_id)
    end

    render json: {}, status: :ok
  end

  private

  def reservation_roomy_id
    @reservation_roomy_id ||= params[:reservation_id]
  end
end
