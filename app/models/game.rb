class Game < ApplicationRecord
  has_many :turns, dependent: :destroy
end
