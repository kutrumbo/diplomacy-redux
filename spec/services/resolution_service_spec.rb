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
        # Vienna successfully attacks Bohemia supported by Galicia
        bohemia_pos = create_position(nationality: Position::GERMANY, area: 'Bohemia', turn: turn, player: players_by_nationality[Position::GERMANY], unit_type: Position::ARMY)
        create_order(position: bohemia_pos, order_type: Order::HOLD, resolution: Order::FAILED)
        galicia_pos = create_position(nationality: Position::AUSTRIA, area: 'Galicia', turn: turn, player: players_by_nationality[Position::AUSTRIA], unit_type: Position::ARMY)
        create_order(position: galicia_pos, order_type: Order::SUPPORT, area_from: 'Vienna', area_to: 'Bohemia', resolution: Order::SUCCEEDED)
        vienna_pos = create_position(nationality: Position::AUSTRIA, area: 'Vienna', turn: turn, player: players_by_nationality[Position::AUSTRIA], unit_type: Position::ARMY)
        create_order(position: vienna_pos, order_type: Order::MOVE, area_to: 'Bohemia', resolution: Order::SUCCEEDED)

        # not occupied, but owned supply center
        create_position(nationality: Position::AUSTRIA, area: 'Budapest', turn: turn, player: players_by_nationality[Position::AUSTRIA])
      end

      it 'creates the appropriate positions for next turn' do
        expect(next_turn.positions.count).to eq(4)

        # expect both Germany and Austria positions in Bohemia, but Germany position is dislodged
        bohemia_positions = next_turn.positions.where(area: Area.find_by_name('Bohemia'))
        expect(bohemia_positions).to_not be_nil
        expect(bohemia_positions.size).to eq(2)
        germany_bohemia_position = bohemia_positions.find { |p| p.player == players_by_nationality[Position::GERMANY] }
        expect(germany_bohemia_position.dislodged).to eq(true)
        austria_bohemia_position = bohemia_positions.find { |p| p.player == players_by_nationality[Position::AUSTRIA] }
        expect(austria_bohemia_position.dislodged).to eq(false)

        # successful supporting order from Galicia stays
        expect(next_turn.positions.find_by(area: Area.find_by_name('Galicia'))).to_not be_nil

        # unoccupied, but owned supply center stays
        expect(next_turn.positions.find_by(area: Area.find_by_name('Budapest'))).to_not be_nil
      end
    end
  end
end
