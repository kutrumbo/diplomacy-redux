module PathService

  def self.supportable_areas(position)
    if position.fleet?
      fleet_possible_paths(position).map { |path| path.last.first }
    else
      GeographyService.neighbors(position.area).select { |a| a.land? }
    end
  end

  def self.possible_paths(position, other_unit_positions)
    if position.fleet?
      fleet_possible_paths(position)
    else
      army_possible_paths(position, other_unit_positions, [position.area])
    end.reject do |path|
      path.first == path.last
    end.uniq
  end

  def self.requires_convoy?(from, to)
    # TODO: does not handle convoying to adjacent coast
    !GeographyService.neighbors(from).include?(to)
  end

  def self.valid_destination?(order, positions)
    destinations = PathService.possible_paths(order.position, positions.without(order.position)).map(&:last)

    if order.position.army? || !order.area_to.coasts?
      destinations.find { |destination| (destination.is_a?(Array) ? destination.first : destination) == order.area_to }.present?
    else
      destinations.find { |destination| destination.is_a?(Array) && (destination.first == order.area_to) && (destination.last == order.coast_to) }.present?
    end
  end

  private

  def self.fleet_accessible(area)
    GeographyService.neighbors(area).select do |neighbor|
      neighbor.sea? || area.borders.find_by(neighbor: neighbor).coastal?
    end
  end

  def self.fleet_possible_paths(position)
    paths = []
    fleet_accessible(position.area).reject do |area|
      position.coast.present? && !GeographyService.neighbors(area).include?(position.coast)
    end.map do |destination|
      from = [position.area, position.coast]
      if destination.coasts?
        destination.coasts.select { |coast| position.area.borders.where(coast: coast).present? }.each do |coast|
          paths << [from, [destination, coast]]
        end
      else
        paths << [from, [destination, nil]]
      end
    end
    paths
  end

  # Returns paths that an army can move to directly or via convoy
  def self.army_possible_paths(current_position, remaining_positions, current_path, paths=[])
    GeographyService.neighbors(current_position.area).each do |neighboring_area|
      paths << [*current_path, neighboring_area] if neighboring_area.land?

      convoy_position = remaining_positions.find do |position|
        position.fleet? && position.area.sea? && position.area_id == neighboring_area.id
      end

      if convoy_position.present?
        army_possible_paths(
          convoy_position,
          remaining_positions.without(current_position, convoy_position),
          [*current_path, neighboring_area],
          paths,
        )
      end
    end
    paths
  end
end
