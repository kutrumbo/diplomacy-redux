class Turn < ApplicationRecord
  # disable single-table inheritance so we can use field name 'type'
  self.inheritance_column = :_type_disabled

  SPRING = 'spring'.freeze
  SPRING_RETREAT = 'spring_retreat'.freeze
  FALL = 'fall'.freeze
  FALL_RETREAT = 'fall_retreat'.freeze
  WINTER = 'winter'.freeze

  TURN_TYPES = [
    SPRING,
    SPRING_RETREAT,
    FALL,
    FALL_RETREAT,
    WINTER,
  ].freeze

  belongs_to :game
  has_many :positions, dependent: :destroy
  has_many :orders, through: :positions

  validates_inclusion_of :type, in: TURN_TYPES

  def year
    1901 + (number / 5)
  end

  def attack?
    [SPRING, FALL].include?(self.type)
  end

  def retreat?
    [SPRING_RETREAT, FALL_RETREAT].include?(self.type)
  end

  def fall?
    self.type == FALL
  end

  def fall_retreat?
    self.type == FALL_RETREAT
  end

  def spring?
    self.type == SPRING
  end

  def build?
    self.type == WINTER
  end

  def complete?
    self.orders.all?(&:confirmed?)
  end

  def previous_turn
    self.game.turns.find_by(number: self.number - 1)
  end
end
