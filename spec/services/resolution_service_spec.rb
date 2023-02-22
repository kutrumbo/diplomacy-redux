require 'rails_helper'

describe 'ResolutionService' do
  subject { ResolutionService }

  describe '.process_orders' do
    let(:turn) { create(:turn, type: turn_type) }
    let(:next_turn) { TurnService.create_next_turn(turn) }
    let(:players_by_nationality) do
      Position::NATIONALITIES.map do |nationality|
        Player.create!(game: turn.game, nationality: nationality)
      end.group_by(&:nationality).transform_values(&:first)
    end

    before do
      build_orders_and_positions
      ResolutionService.process_orders(turn.reload, next_turn)
      next_turn.reload
    end

    context 'spring' do
      let(:turn_type) { Turn::SPRING }
      let(:build_orders_and_positions) do
        # TODO
      end

      it 'creates the appropriate positions for next turn'
    end
  end
end
