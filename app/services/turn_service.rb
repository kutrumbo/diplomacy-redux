module TurnService
  WINNING_SUPPLY_CENTER_AMOUNT = 18

  def self.process_turn(turn)
    return if turn.number < turn.game.current_turn.number

    ActiveRecord::Base.transaction do
      if turn.complete?
        AdjudicationService.new(turn.orders).adjudicate

        turn.orders.each(&:save!)

        next_turn = self.create_next_turn(turn.reload)
        ResolutionService.process_orders(turn, next_turn)

        next_turn.reload

        # if there is a victor, complete game
        if victor = self.determine_victor(next_turn)
          # TODO: set victor of game
          return
        end

        if next_turn.attack?
          next_turn.positions.with_unit.each { |p| Order.create!(position: p) }
        elsif next_turn.retreat?
          next_turn.positions.dislodged.each { |p| Order.create!(position: p) }
        else
          # TODO: create build/disband orders as necessary
        end

        # if no orders (i.e. no builds/disbands), immediately process turn
        if next_turn.reload.orders.empty?
          self.process_turn(next_turn)
        end
      end
    end
  end

  def self.determine_victor(next_turn)
    # TODO: should only trigger at end of Fall move
    next_turn.positions.with_unit.supply_center.group(:nationality).count.find do |_, count|
      count >= WINNING_SUPPLY_CENTER_AMOUNT
    end&.first
  end

  def self.create_next_turn(turn)
    turn.game.turns.create!(
      number: turn.number + 1,
      type: next_turn_type(turn),
    )
  end

  def self.next_turn_type(turn)
    Turn::TURN_TYPES[Turn::TURN_TYPES.index(turn.type) + 1] || Turn::TURN_TYPES.first
  end
end
