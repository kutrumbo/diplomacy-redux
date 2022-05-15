class Area < ApplicationRecord
  LAND = 'land'.freeze
  SEA = 'sea'.freeze
  TYPES = [LAND, SEA].freeze

  has_many :borders
  has_many :neighbors, through: :borders, class_name: 'Area', foreign_key: 'neighbor_id'
  has_many :coasts

  validates_inclusion_of :area_type, in: TYPES

  scope :land, -> { where(area_type: LAND) }
  scope :sea, -> { where(area_type: SEA) }
  scope :supply_center, -> { where(supply_center: true) }

  def coasts?
    self.coasts.present?
  end

  def coastal?
    self.land? && self.neighbors.sea.any?
  end

  def sea?
    self.area_type == SEA
  end

  def land?
    self.area_type == LAND
  end
end
