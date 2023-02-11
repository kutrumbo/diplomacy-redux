module Api
  class GamesController < ApplicationController
    def show
      game = Game.find(params[:id])
      current_turn = game.current_turn
      # TODO: should only show own orders once we implement users
      render json: game.as_json.merge(
        orders: current_turn.orders,
        players: game.players,
        positions: current_turn.positions,
        turn: current_turn,
        year: current_turn.year,
        turns: game.turns.where.not(id: current_turn),
        past_orders: game.orders.where.not(id: current_turn.orders).includes(:position).as_json(include: :position),
      )
    end

    def update_orders
      game = Game.find(params[:game_id])
      current_turn = game.current_turn
      updated_orders = params.permit(orders: [:id, :confirmed, :order_type, :area_from_id, :area_to_id])[:orders]

      ActiveRecord::Base.transaction do
        updated_orders.each do |updated_order|
          current_turn.orders.find(updated_order[:id]).update!(updated_order)
        end
        TurnService.process_turn(current_turn.reload)
      end

      render json: { success: true }
    end
  end
end
