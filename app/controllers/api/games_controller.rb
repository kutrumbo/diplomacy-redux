module Api
  class GamesController < ApplicationController
    def show
      render json: Game.find(params[:id])
    end
  end
end
