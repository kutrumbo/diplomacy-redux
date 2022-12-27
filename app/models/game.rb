class Game < ApplicationRecord
  has_many :turns, dependent: :destroy
  has_many :players, dependent: :destroy

  def current_turn
    self.turns.order(:number).last
  end
end
