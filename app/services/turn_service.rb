module TurnService
  WINNING_SUPPLY_CENTER_AMOUNT = 18

  def self.process_turn(turn)
    return if turn.number < turn.game.current_turn.number

    ActiveRecord::Base.transaction do
      if turn.complete?
        AdjudicationService.new(turn.orders).adjudicate if turn.orders.present?

        turn.orders.each(&:save!)

        next_turn = self.create_next_turn(turn.reload)
        ResolutionService.process_orders(turn, next_turn)

        next_turn.reload

        # if there is any victor, complete game
        if victors = self.determine_victors(next_turn) && victors.present?
          # TODO: set victor of game
          return
        end

        if next_turn.attack?
          next_turn.positions.with_unit.each { |p| Order.create!(position: p) }
        elsif next_turn.retreat?
          next_turn.positions.dislodged.each { |p| Order.create!(position: p) }
        else
          num_of_supply_centers_by_player = next_turn.positions.supply_center.group(:player_id).count
          next_turn.positions.with_unit.group(:player_id).count.each do |player_id, count|
            if count > num_of_supply_centers_by_player[player_id]
              # create disband orders
              next_turn.positions.with_unit.where(player_id: player_id).each { |p| Order.create!(position: p) }
            elsif count < num_of_supply_centers_by_player[player_id]
              # create build orders
              player_nationality = turn.game.players.find(player_id).nationality
              next_turn.positions.where(player_id: player_id).
                joins(:area).
                merge(Area.supply_center.with_nationality(player_nationality)).
                without_unit.
                each { |p| Order.create!(position: p) }
            end
          end
        end

        # if no orders (i.e. no builds/disbands), immediately process turn
        if next_turn.reload.orders.empty?
          self.process_turn(next_turn)
        end
      end
    end
  end

  def self.determine_victors(next_turn)
    # TODO: should only trigger at end of Fall move
    next_turn.positions.with_unit.supply_center.group(:player_id).count.select do |_, count|
      count >= WINNING_SUPPLY_CENTER_AMOUNT
    end
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
