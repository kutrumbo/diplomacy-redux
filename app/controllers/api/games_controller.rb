module Api
  class GamesController < ApplicationController
    def show
      game = Game.find(params[:id])
      current_turn = game.current_turn
      # TODO: should only show own orders once we implement users
      render json: game.as_json.merge(turn: current_turn, positions: current_turn.positions, orders: current_turn.orders)
    end
  end
end
