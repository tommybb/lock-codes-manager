class Reservation < ApplicationRecord
  belongs_to :room, inverse_of: :reservations
  belongs_to :guest, inverse_of: :reservations
end
