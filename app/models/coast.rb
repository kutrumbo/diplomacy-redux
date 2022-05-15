class Coast < ApplicationRecord
  DIRECTIONS = %w(north east south).freeze

  belongs_to :area

  validates_inclusion_of :direction, in: DIRECTIONS
end
