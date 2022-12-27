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

    # process positions without a unit
    previous_turn.positions.without_unit.each do |position|
      became_occupied = previous_turn.orders.move.succeeded.where(area_to: position.area).present?

      unless became_occupied
        new_position = position.dup
        new_position.update!(turn: next_turn)
      end
    end

    # TODO: set nationality if winter
  end

  def self.process_retreat_turn(previous_turn, next_turn)
    previous_turn.positions.each do |position|
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
  end

  def self.process_build_turn(previous_turn, next_turn)
    # TODO:
    previous_turn.positions.each do |position|
      new_position = position.dup
      new_position.update!(turn: next_turn)
    end
  end
end
