module ResolutionService

  def self.process_orders(turn, next_turn)
    # NOTE: this method is wrapped in a transaction in the calling class, so does not need a transaction of its own
    next_turn = self.create_next_turn(turn)

    # TODO: process orders/positions
  end
end
