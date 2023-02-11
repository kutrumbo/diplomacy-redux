module Helpers
  def find_area(area_name)
    area_model = area_name && Area.find_by_name(area_name)
    raise "Invalid area name: #{area_name}" if (area_name && !area_model)
    area_model
  end

  def build_position(nationality: Position::AUSTRIA, area:, unit_type: nil, coast: nil, turn: nil, player: nil)
    area_model = find_area(area)
    coast_model = coast && area_model.coasts.find_by(direction: coast)
    raise "Invalid coast direction: #{coast} for area: #{area_name}" if (coast && !coast_model)
    build(:position,
      nationality: nationality,
      area: area_model,
      coast: coast_model,
      unit_type: unit_type,
      turn: turn || Turn.new(type: Turn::SPRING),
      player: player || Player.new(nationality: nationality)
    )
  end

  def create_position(nationality: Position::AUSTRIA, area:, unit_type: nil, coast: nil, turn: nil, player: nil)
    position = build_position(nationality: nationality, area: area, unit_type: unit_type, coast: coast, turn: turn, player: player)
    position.save!
    position
  end

  def build_order(position:, order_type:, area_from: nil, area_to: nil, coast_to: nil, resolution: nil)
    area_to_model = find_area(area_to)
    coast_model = coast_to && area_to_model.coasts.find_by(direction: coast_to)
    raise "Invalid coast direction: #{coast_to} for area: #{area_to}" if (coast_to && !coast_model)
    area_from_model = if area_from
      find_area(area_from)
    elsif order_type == Order::MOVE
      position.area
    end
    build(:order, position: position, order_type: order_type, area_from: area_from_model, area_to: area_to_model, coast_to: coast_model, resolution: resolution)
  end

  def create_order(position:, order_type:, area_from: nil, area_to: nil, coast_to: nil, resolution: nil)
    order = build_order(position: position, order_type: order_type, area_from: area_from, area_to: area_to, coast_to: coast_to, resolution: resolution)
    order.save!
    order
  end
end
