module TurnService
  WINNING_SUPPLY_CENTER_AMOUNT = 18

  def self.process_turn(turn)
    return if turn.number < turn.game.current_turn.number

    ActiveRecord::Base.transaction do
      if turn_complete?(turn)
        AdjudicationService.new(turn.orders).adjudicate

        next_turn = self.create_next_turn(turn.reload)
        ResolutionService.process_orders(turn, next_turn)


        # check if there is a winner
        # if not, create orders
          # if no orders (i.e. no builds/disbands), immediately process turn
      end
    end
  end

  def self.determine_victor(next_turn)
    # TODO: should only trigger at end of Fall move
    next_turn.positions.occupied.supply_center.group(:user_game_id).count.find do |_, count|
      count >= WINNING_SUPPLY_CENTER_AMOUNT
    end&.first
  end

  def self.turn_complete?(turn)
    turn.orders.all?(&:confirmed?)
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
