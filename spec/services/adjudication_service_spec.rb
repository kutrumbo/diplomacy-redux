require 'rails_helper'

describe 'AdjudicationService' do
  subject { AdjudicationService }

  # adjudication test cases referenced from: http://web.inter.nl.net/users/L.B.Kruijswijk/#6
  describe '#adjudicate' do
    specify 'A.1 TEST CASE, MOVING TO AN AREA THAT IS NOT A NEIGHBOUR' do
      position = build_position(area: 'North Sea', unit_type: Position::FLEET)
      order = build_order(position: position, order_type: Order::MOVE, area_to: 'Picardy')

      subject.new([order]).adjudicate
      expect(order.resolution).to eq(Order::FAILED)
    end

    specify 'A.2. TEST CASE, MOVE ARMY TO SEA' do
      position = build_position(area: 'Liverpool', unit_type: Position::ARMY)
      order = build_order(position: position, order_type: Order::MOVE, area_to: 'Irish Sea')

      subject.new([order]).adjudicate
      expect(order.resolution).to eq(Order::FAILED)
    end

    specify 'A.3. TEST CASE, MOVE FLEET TO LAND' do
      position = build_position(area: 'Kiel', unit_type: Position::FLEET)
      order = build_order(position: position, order_type: Order::MOVE, area_to: 'Munich')

      subject.new([order]).adjudicate
      expect(order.resolution).to eq(Order::FAILED)
    end

    specify 'A.4. TEST CASE, MOVE TO OWN SECTOR' do
      position = build_position(area: 'Kiel', unit_type: Position::FLEET)
      order = build_order(position: position, order_type: Order::MOVE, area_to: 'Kiel')

      subject.new([order]).adjudicate
      expect(order.resolution).to eq(Order::FAILED)
    end

    specify 'A.5. TEST CASE, MOVE TO OWN SECTOR WITH CONVOY'

    # A.6. TEST CASE, ORDERING A UNIT OF ANOTHER COUNTRY is not applicable because orders are associated with a position

    specify 'A.7. TEST CASE, ONLY ARMIES CAN BE CONVOYED' do
      london_fleet = build_position(area: 'London', unit_type: Position::FLEET)
      north_sea_fleet = build_position(area: 'North Sea', unit_type: Position::FLEET)
      convoy_order = build_order(position: north_sea_fleet, order_type: Order::CONVOY, area_from: 'London', area_to: 'Belgium')
      move_order = build_order(position: london_fleet, order_type: Order::MOVE, area_to: 'Belgium')
      orders = [convoy_order, move_order]

      subject.new(orders).adjudicate
      expect(move_order.resolution).to eq(Order::FAILED)
    end

    specify 'A.8. TEST CASE, SUPPORT TO HOLD YOURSELF IS NOT POSSIBLE' do
      venice_army = build_position(nationality: Position::AUSTRIA, area: 'Venice', unit_type: Position::ARMY)
      tyrolia_army = build_position(nationality: Position::AUSTRIA, area: 'Tyrolia', unit_type: Position::ARMY)
      trieste_army = build_position(nationality: Position::ITALY, area: 'Trieste', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::MOVE, area_to: 'Trieste')
      tyrolia_order = build_order(position: tyrolia_army, order_type: Order::SUPPORT, area_from: 'Venice', area_to: 'Trieste')
      trieste_order = build_order(position: trieste_army, order_type: Order::SUPPORT, area_from: 'Trieste', area_to: 'Trieste')
      orders = [venice_order, tyrolia_order, trieste_order]

      subject.new(orders).adjudicate
      expect(trieste_order.resolution).to eq(Order::FAILED)
    end

    specify 'A.9. TEST CASE, FLEETS MUST FOLLOW COAST IF NOT ON SEA' do
      rome_fleet = build_position(area: 'Rome', unit_type: Position::FLEET)
      order = build_order(position: rome_fleet, order_type: Order::MOVE, area_to: 'Venice')

      subject.new([order]).adjudicate
      expect(order.resolution).to eq(Order::FAILED)
    end

    specify 'A.10. TEST CASE, SUPPORT ON UNREACHABLE DESTINATION NOT POSSIBLE' do
      rome_fleet = build_position(nationality: Position::ITALY, area: 'Rome', unit_type: Position::FLEET)
      rome_order = build_order(position: rome_fleet, order_type: Order::SUPPORT, area_from: 'Apulia', area_to: 'Venice')
      apulia_army = build_position(nationality: Position::ITALY, area: 'Apulia', unit_type: Position::ARMY)
      apulia_order = build_order(position: apulia_army, order_type: Order::MOVE, area_to: 'Venice')
      venice_army = build_position(nationality: Position::AUSTRIA, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::HOLD)
      orders = [rome_order, apulia_order, venice_order]

      subject.new(orders).adjudicate
      expect(rome_order.resolution).to eq(Order::FAILED)
    end

    specify 'A.11. TEST CASE, SIMPLE BOUNCE' do
      venice_army = build_position(nationality: Position::ITALY, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::MOVE, area_to: 'Tyrolia')
      vienna_army = build_position(nationality: Position::AUSTRIA, area: 'Vienna', unit_type: Position::ARMY)
      vienna_order = build_order(position: vienna_army, order_type: Order::MOVE, area_to: 'Tyrolia')
      orders = [venice_order, vienna_order]

      subject.new(orders).adjudicate
      expect(venice_order.resolution).to eq(Order::FAILED)
      expect(vienna_order.resolution).to eq(Order::FAILED)
    end
  end
end
