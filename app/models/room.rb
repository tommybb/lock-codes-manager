class Room < ApplicationRecord
  has_many :reservations, inverse_of: :room
end
