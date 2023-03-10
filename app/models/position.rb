class Position < ApplicationRecord
  ARMY = 'army'.freeze
  FLEET = 'fleet'.freeze
  UNIT_TYPES = [ARMY, FLEET].freeze

  AUSTRIA = 'austria'.freeze
  ENGLAND = 'england'.freeze
  FRANCE = 'france'.freeze
  GERMANY = 'germany'.freeze
  ITALY = 'italy'.freeze
  RUSSIA = 'russia'.freeze
  TURKEY = 'turkey'.freeze
  NATIONALITIES = [
    AUSTRIA,
    ENGLAND,
    FRANCE,
    GERMANY,
    ITALY,
    RUSSIA,
    TURKEY,
  ].freeze

  belongs_to :area
  belongs_to :coast, optional: true
  belongs_to :player
  belongs_to :turn
  has_one :order, dependent: :destroy

  validates_inclusion_of :unit_type, in: UNIT_TYPES, allow_nil: true
  validates_inclusion_of :nationality, in: NATIONALITIES, allow_nil: true

  scope :supply_center, -> { joins(:area).merge(Area.supply_center) }
  scope :dislodged, -> { where(dislodged: true) }
  scope :with_unit, -> { where.not(unit_type: nil) }
  scope :without_unit, -> { where(unit_type: nil) }

  def unit?
    self.unit_type.present?
  end

  def army?
    self.unit_type == ARMY
  end

  def fleet?
    self.unit_type == FLEET
  end
end
