class Game < ApplicationRecord
  has_many :turns, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :positions, through: :turns
  has_many :orders, through: :positions

  def current_turn
    self.turns.order(:number).last
  end
end
