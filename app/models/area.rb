class Area < ApplicationRecord
  LAND = 'land'.freeze
  SEA = 'sea'.freeze
  AREA_TYPES = [LAND, SEA].freeze

  has_many :borders
  has_many :neighbors, through: :borders, class_name: 'Area', foreign_key: 'neighbor_id'
  has_many :coasts

  validates_inclusion_of :area_type, in: AREA_TYPES

  scope :land, -> { where(area_type: LAND) }
  scope :sea, -> { where(area_type: SEA) }
  scope :supply_center, -> { where(supply_center: true) }
  scope :has_coasts, -> { joins(:coasts).distinct }
  scope :with_nationality, ->(nationality) { where(nationality: nationality) }

  def supply_center?
    self.supply_center.present?
  end

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
