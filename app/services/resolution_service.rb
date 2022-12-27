module ResolutionService

  def self.process_orders(previous_turn, next_turn)
    # NOTE: this method is wrapped in a transaction in the calling class, so does not need a transaction of its own
    current_positions = previous_turn.positions

    # TODO: handle build/retreat orders
    if previous_turn.attack?
      self.process_attack_turn(previous_turn, next_turn)
    elsif previous_turn.retreat?
    else
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

    # process non-move orders
    previous_turn.orders.non_move.each do |order|
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
  end
end
