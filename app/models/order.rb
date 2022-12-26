class Order < ApplicationRecord
  BUILD_ARMY = 'build_army'.freeze
  BUILD_FLEET = 'build_fleet'.freeze
  CONVOY = 'convoy'.freeze
  DISBAND = 'disband'.freeze
  HOLD = 'hold'.freeze
  MOVE = 'move'.freeze
  RETREAT = 'retreat'.freeze
  SUPPORT = 'support'.freeze

  ORDER_TYPES = [
    BUILD_ARMY,
    BUILD_FLEET,
    CONVOY,
    DISBAND,
    HOLD,
    MOVE,
    RETREAT,
    SUPPORT,
  ].freeze

  FAILED = 'failed'.freeze
  SUCCEEDED = 'succeeded'.freeze

  RESOLUTIONS = [
    FAILED,
    SUCCEEDED,
  ].freeze

  belongs_to :position
  has_one :turn, through: :position
  belongs_to :area_from, class_name: 'Area', optional: true
  belongs_to :area_to, class_name: 'Area', optional: true
  belongs_to :coast_from, class_name: 'Coast', optional: true
  belongs_to :coast_to, class_name: 'Coast', optional: true

  validates_inclusion_of :resolution, in: RESOLUTIONS, allow_nil: true
  validates_inclusion_of :order_type, in: ORDER_TYPES, allow_nil: true

  after_update { |order| TurnService.process_turn(order.turn) }

  RESOLUTIONS.each do |resolution|
    define_method("#{resolution}?") do
      self.resolution == resolution
    end
  end

  ORDER_TYPES.each do |order_type|
    define_method("#{order_type}?") do
      self.order_type == order_type
    end
  end

  def confirmed?
    self.order_type.present? && self.area_from_id.present? && self.area_to_id.present?
  end

  def resolved?
    self.resolution.present?
  end

  def unresolved?
    self.resolution.nil?
  end
end
