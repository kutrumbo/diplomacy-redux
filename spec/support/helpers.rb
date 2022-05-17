module Helpers
  def find_area(area_name)
    area_model = area_name && Area.find_by_name(area_name)
    raise "Invalid area name: #{area_name}" if (area_name && !area_model)
    area_model
  end

  def build_position(nationality: Position::AUSTRIA, area:, unit_type:, coast: nil)
    build(:position, nationality: nationality, area: find_area(area), coast: coast, unit_type: unit_type)
  end

  def build_order(position:, order_type:, area_from: nil, area_to: nil)
    build(:order, position: position, order_type: order_type, area_from: find_area(area_from), area_to: find_area(area_to))
  end
end
