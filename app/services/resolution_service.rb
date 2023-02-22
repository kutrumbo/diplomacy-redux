module ResolutionService

  def self.process_orders(previous_turn, next_turn)
    # NOTE: this method is wrapped in a transaction in the calling class, so does not need a transaction of its own
    current_positions = previous_turn.positions

    # TODO: handle build/retreat orders
    if previous_turn.attack?
      self.process_attack_turn(previous_turn, next_turn)
    elsif previous_turn.retreat?
      self.process_retreat_turn(previous_turn, next_turn)
    else
      self.process_build_turn(previous_turn, next_turn)
    end
  end

  def self.process_attack_turn(previous_turn, next_turn)
    # if beginning of year, create non-unit positions for all occupied supply centers
    if previous_turn.spring?
      previous_turn.positions.supply_center.with_unit.each do |position|
        position.dup.update!(unit_type: nil, turn: next_turn)
      end
    end

    # process successful move orders first
    previous_turn.orders.move.succeeded.each do |order|
      new_position = order.position.dup
      previous_nationality = previous_turn.positions.where(area: order.area_to).pluck(:nationality).compact.first

      new_position.update!(
        area: order.area_to,
        coast: order.coast_to,
        turn: next_turn,
        nationality: previous_nationality,
      )
    end

    # process non-move and failed move orders
    previous_turn.orders.non_move.or(previous_turn.orders.move.failed).each do |order|
      new_position = order.position.dup

      # check to see if they should be dislodged by seeing if there were any successful attacks against
      is_dislodged = previous_turn.orders.move.succeeded.any? do |attacking_order|
        attacking_order.area_to == order.position.area
      end

      new_position.update!(
        dislodged: is_dislodged,
        turn: next_turn,
      )
    end

    # positions without a unit should remain
    previous_turn.positions.without_unit.each do |position|
      position.dup.update!(turn: next_turn)
    end
  end

  def self.process_retreat_turn(previous_turn, next_turn)
    previous_turn.positions.with_unit.each do |position|
      new_position = position.dup
      if position.order.present?
        next if position.order.disband?
        next if (position.order.retreat? && position.order.failed?)
      end

      new_position.update!(
        turn: next_turn,
        area: position.order.present? ? position.order.area_to : position.area,
        coast: position.order.present? ? position.order.coast_to : position.coast,
        dislodged: false,
      )
    end

    next_turn.reload
    occupied_area_ids = next_turn.reload.positions.pluck(:area_id)

    previous_turn.positions.without_unit.each do |position|
      # do not replicate positions without a unit if area is occupied going into the build turn
      next if (next_turn.build? && occupied_area_ids.include?(position.area_id))
      position.dup.update!(turn: next_turn)
    end
  end

  def self.process_build_turn(previous_turn, next_turn)
    previous_turn.positions.with_unit.each do |position|
      next if position.order&.disband?
      new_position = position.dup
      new_position.update!(turn: next_turn)
    end

    previous_turn.positions.without_unit.joins(:order).each do |position|
      if position.order.succeeded?
        new_position = position.dup
        new_unit_type = position.order.build_army? ? Position::ARMY : Position::FLEET
        new_position.update!(unit_type: new_unit_type, turn: next_turn)
      end
    end
  end
end
