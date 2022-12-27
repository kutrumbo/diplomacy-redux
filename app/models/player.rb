class Player < ApplicationRecord
  belongs_to :game

  validates_inclusion_of :nationality, in: Position::NATIONALITIES
end
