class Guest < ApplicationRecord
  has_many :reservations, inverse_of: :guest
end
