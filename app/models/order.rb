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
  belongs_to :area_from, class_name: 'Area', optional: true
  belongs_to :area_to, class_name: 'Area', optional: true
  belongs_to :coast_from, class_name: 'Coast', optional: true
  belongs_to :coast_to, class_name: 'Coast', optional: true

  # do not include UNRESOLVED as valid status because we should not persist unresolved orders
  validates_inclusion_of :status, in: [FAILED, SUCCEEDED]
  validates_inclusion_of :order_type, in: ORDER_TYPES

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

  def resolved?
    self.resolution.present?
  end

  def unresolved?
    self.resolution.nil?
  end
end
