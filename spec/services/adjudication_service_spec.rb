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

    # A. TEST CASE, ORDERING A UNIT OF ANOTHER COUNTRY is not applicable because orders are associated with a position

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

    specify 'A.12. TEST CASE, BOUNCE OF THREE UNITS' do
      munich_army = build_position(nationality: Position::GERMANY, area: 'Munich', unit_type: Position::ARMY)
      munich_order = build_order(position: munich_army, order_type: Order::MOVE, area_to: 'Tyrolia')
      venice_army = build_position(nationality: Position::ITALY, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::MOVE, area_to: 'Tyrolia')
      vienna_army = build_position(nationality: Position::AUSTRIA, area: 'Vienna', unit_type: Position::ARMY)
      vienna_order = build_order(position: vienna_army, order_type: Order::MOVE, area_to: 'Tyrolia')
      orders = [munich_order, venice_order, vienna_order]

      subject.new(orders).adjudicate
      expect(munich_order.resolution).to eq(Order::FAILED)
      expect(venice_order.resolution).to eq(Order::FAILED)
      expect(vienna_order.resolution).to eq(Order::FAILED)
    end

    specify 'B.1. TEST CASE, MOVING WITH UNSPECIFIED COAST WHEN COAST IS NECESSARY' do
      fleet = build_position(area: 'Portugal', unit_type: Position::FLEET)
      order = build_order(position: fleet, order_type: Order::MOVE, area_to: 'Spain')

      subject.new([order]).adjudicate
      expect(order.resolution).to eq(Order::FAILED)
    end

    specify 'B.2. TEST CASE, MOVING WITH UNSPECIFIED COAST WHEN COAST IS NOT NECESSARY' do
      fleet = build_position(area: 'Gascony', unit_type: Position::FLEET)
      order = build_order(position: fleet, order_type: Order::MOVE, area_to: 'Spain')

      subject.new([order]).adjudicate
      expect(order.resolution).to eq(Order::FAILED)
    end

    specify 'B.3. TEST CASE, MOVING WITH WRONG COAST WHEN COAST IS NOT NECESSARY' do
      fleet = build_position(area: 'Gascony', unit_type: Position::FLEET)
      order = build_order(position: fleet, order_type: Order::MOVE, area_to: 'Spain', coast_to: 'south')

      subject.new([order]).adjudicate
      expect(order.resolution).to eq(Order::FAILED)
    end

    specify 'B.4. TEST CASE, SUPPORT TO UNREACHABLE COAST ALLOWED' do
      gascony_fleet = build_position(nationality: Position::FRANCE, area: 'Gascony', unit_type: Position::FLEET)
      gascony_order = build_order(position: gascony_fleet, order_type: Order::MOVE, area_to: 'Spain', coast_to: 'north')
      marseilles_fleet = build_position(nationality: Position::FRANCE, area: 'Marseilles', unit_type: Position::FLEET)
      marseilles_order = build_order(position: marseilles_fleet, order_type: Order::SUPPORT, area_from: 'Gascony', area_to: 'Spain', coast_to: 'north')
      western_med_fleet = build_position(nationality: Position::ITALY, area: 'Western Mediterranean', unit_type: Position::FLEET)
      western_med_order = build_order(position: western_med_fleet, order_type: Order::MOVE, area_to: 'Spain', coast_to: 'south')
      orders = [gascony_order, marseilles_order, western_med_order]

      subject.new(orders).adjudicate
      expect(gascony_order.resolution).to eq(Order::SUCCEEDED)
      expect(marseilles_order.resolution).to eq(Order::SUCCEEDED)
      expect(western_med_order.resolution).to eq(Order::FAILED)
    end

    specify 'B.5. TEST CASE, SUPPORT FROM UNREACHABLE COAST NOT ALLOWED' do
      marseilles_fleet = build_position(nationality: Position::FRANCE, area: 'Marseilles', unit_type: Position::FLEET)
      marseilles_order = build_order(position: marseilles_fleet, order_type: Order::MOVE, area_to: 'Gulf of Lyons')
      spain_fleet = build_position(nationality: Position::FRANCE, area: 'Spain', coast: 'north', unit_type: Position::FLEET)
      spain_order = build_order(position: spain_fleet, order_type: Order::SUPPORT, area_from: 'Marseilles', area_to: 'Gulf of Lyons')
      gulf_of_lyon_fleet = build_position(nationality: Position::ITALY, area: 'Gulf of Lyons', unit_type: Position::FLEET)
      gulf_of_lyon_order = build_order(position: gulf_of_lyon_fleet, order_type: Order::HOLD)
      orders = [gulf_of_lyon_order, marseilles_order, spain_order]

      subject.new(orders).adjudicate
      expect(gulf_of_lyon_order.resolution).to eq(Order::SUCCEEDED)
      expect(marseilles_order.resolution).to eq(Order::FAILED)
      expect(spain_order.resolution).to eq(Order::FAILED)
    end

    specify 'B. TEST CASE, SUPPORT CAN BE CUT WITH OTHER COAST' do
      irish_sea_fleet = build_position(nationality: Position::ENGLAND, area: 'Irish Sea', unit_type: Position::FLEET)
      irish_sea_order = build_order(position: irish_sea_fleet, order_type: Order::SUPPORT, area_from: 'North Atlantic Ocean', area_to: 'Mid Atlantic Ocean')
      north_atlantic_fleet = build_position(nationality: Position::ENGLAND, area: 'North Atlantic Ocean', unit_type: Position::FLEET)
      north_atlantic_order = build_order(position: north_atlantic_fleet, order_type: Order::MOVE, area_to: 'Mid Atlantic Ocean')
      spain_fleet = build_position(nationality: Position::FRANCE, area: 'Spain', coast: 'north', unit_type: Position::FLEET)
      spain_order = build_order(position: spain_fleet, order_type: Order::SUPPORT, area_from: 'Mid Atlantic Ocean', area_to: 'Mid Atlantic Ocean')
      mid_atlantic_fleet = build_position(nationality: Position::FRANCE, area: 'Mid Atlantic Ocean', unit_type: Position::FLEET)
      mid_atlantic_order = build_order(position: mid_atlantic_fleet, order_type: Order::HOLD)
      gulf_of_lyon_fleet = build_position(nationality: Position::ITALY, area: 'Gulf of Lyons', unit_type: Position::FLEET)
      gulf_of_lyon_order = build_order(position: gulf_of_lyon_fleet, order_type: Order::MOVE, area_to: 'Spain', coast_to: 'south')
      orders = [irish_sea_order, north_atlantic_order, spain_order, mid_atlantic_order, gulf_of_lyon_order]

      subject.new(orders).adjudicate
      expect(mid_atlantic_order.resolution).to eq(Order::FAILED)
    end

    specify 'B.7. TEST CASE, SUPPORTING WITH UNSPECIFIED COAST' do
      portugal_fleet = build_position(nationality: Position::FRANCE, area: 'Portugal', unit_type: Position::FLEET)
      portugal_order = build_order(position: portugal_fleet, order_type: Order::SUPPORT, area_from: 'Mid Atlantic Ocean', area_to: 'Spain')
      mid_atlantic_fleet = build_position(nationality: Position::FRANCE, area: 'Mid Atlantic Ocean', unit_type: Position::FLEET)
      mid_atlantic_order = build_order(position: mid_atlantic_fleet, order_type: Order::MOVE, area_to: 'Spain', coast_to: 'north')
      gulf_of_lyon_fleet = build_position(nationality: Position::ITALY, area: 'Gulf of Lyons', unit_type: Position::FLEET)
      gulf_of_lyon_order = build_order(position: gulf_of_lyon_fleet, order_type: Order::SUPPORT, area_from: 'Western Mediterranean', area_to: 'Spain')
      western_med_fleet = build_position(nationality: Position::ITALY, area: 'Western Mediterranean', unit_type: Position::FLEET)
      western_med_order = build_order(position: western_med_fleet, order_type: Order::MOVE, area_to: 'Spain', coast_to: 'south')
      orders = [portugal_order, mid_atlantic_order, gulf_of_lyon_order, western_med_order]

      subject.new(orders).adjudicate
      expect(mid_atlantic_order.resolution).to eq(Order::FAILED)
      expect(western_med_order.resolution).to eq(Order::FAILED)
    end

    # testing same condition as B.7.
    # specify 'B.8. TEST CASE, SUPPORTING WITH UNSPECIFIED COAST WHEN ONLY ONE COAST IS POSSIBLE'
    # not applicable to order schema
    # specify 'B.9. TEST CASE, SUPPORTING WITH WRONG COAST'
    # specify 'B.10. TEST CASE, UNIT ORDERED WITH WRONG COAST'
    # specify 'B.11. TEST CASE, COAST CAN NOT BE ORDERED TO CHANGE'
    # specify 'B.12. TEST CASE, ARMY MOVEMENT WITH COASTAL SPECIFICATION'

    specify 'B.13. TEST CASE, COASTAL CRAWL NOT ALLOWED' do
      bulgaria_fleet = build_position(nationality: Position::TURKEY, area: 'Bulgaria', coast: 'south', unit_type: Position::FLEET)
      bulgaria_order = build_order(position: bulgaria_fleet, order_type: Order::MOVE, area_to: 'Constantinople')
      constantinople_fleet = build_position(nationality: Position::TURKEY, area: 'Constantinople',  unit_type: Position::FLEET)
      constantinople_order = build_order(position: constantinople_fleet, order_type: Order::MOVE, area_to: 'Bulgaria', coast_to: 'east')
      orders = [bulgaria_order, constantinople_order]

      subject.new(orders).adjudicate
      expect(bulgaria_order.resolution).to eq(Order::FAILED)
      expect(constantinople_order.resolution).to eq(Order::FAILED)
    end

    specify 'B.14. TEST CASE, BUILDING WITH UNSPECIFIED COAST'

    specify 'C.1. TEST CASE, THREE ARMY CIRCULAR MOVEMENT' do
      ankara_army = build_position(area: 'Ankara', unit_type: Position::ARMY)
      ankara_order = build_order(position: ankara_army, order_type: Order::MOVE, area_to: 'Constantinople')
      constantinople_army = build_position(area: 'Constantinople', unit_type: Position::ARMY)
      constantinople_order = build_order(position: constantinople_army, order_type: Order::MOVE, area_to: 'Smyrna')
      smyrna_army = build_position(area: 'Smyrna', unit_type: Position::ARMY)
      smyrna_order = build_order(position: smyrna_army, order_type: Order::MOVE, area_to: 'Ankara')
      orders = [ankara_order, constantinople_order, smyrna_order]

      subject.new(orders).adjudicate
      expect(ankara_order.resolution).to eq(Order::SUCCEEDED)
      expect(constantinople_order.resolution).to eq(Order::SUCCEEDED)
      expect(smyrna_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'C.2. TEST CASE, THREE ARMY CIRCULAR MOVEMENT WITH SUPPORT' do
      ankara_army = build_position(area: 'Ankara', unit_type: Position::ARMY)
      ankara_order = build_order(position: ankara_army, order_type: Order::MOVE, area_to: 'Constantinople')
      constantinople_army = build_position(area: 'Constantinople', unit_type: Position::ARMY)
      constantinople_order = build_order(position: constantinople_army, order_type: Order::MOVE, area_to: 'Smyrna')
      smyrna_army = build_position(area: 'Smyrna', unit_type: Position::ARMY)
      smyrna_order = build_order(position: smyrna_army, order_type: Order::MOVE, area_to: 'Ankara')
      bulgaria_army = build_position(area: 'Bulgaria', unit_type: Position::ARMY)
      bulgaria_order = build_order(position: bulgaria_army, order_type: Order::SUPPORT, area_from: 'Ankara', area_to: 'Constantinople')
      orders = [ankara_order, constantinople_order, smyrna_order, bulgaria_order]

      subject.new(orders).adjudicate
      expect(ankara_order.resolution).to eq(Order::SUCCEEDED)
      expect(constantinople_order.resolution).to eq(Order::SUCCEEDED)
      expect(smyrna_order.resolution).to eq(Order::SUCCEEDED)
      expect(bulgaria_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'C.3. TEST CASE, A DISRUPTED THREE ARMY CIRCULAR MOVEMENT' do
      ankara_army = build_position(area: 'Ankara', unit_type: Position::ARMY)
      ankara_order = build_order(position: ankara_army, order_type: Order::MOVE, area_to: 'Constantinople')
      constantinople_army = build_position(area: 'Constantinople', unit_type: Position::ARMY)
      constantinople_order = build_order(position: constantinople_army, order_type: Order::MOVE, area_to: 'Smyrna')
      smyrna_army = build_position(area: 'Smyrna', unit_type: Position::ARMY)
      smyrna_order = build_order(position: smyrna_army, order_type: Order::MOVE, area_to: 'Ankara')
      bulgaria_army = build_position(area: 'Bulgaria', unit_type: Position::ARMY)
      bulgaria_order = build_order(position: bulgaria_army, order_type: Order::MOVE, area_to: 'Constantinople')
      orders = [ankara_order, constantinople_order, smyrna_order, bulgaria_order]

      subject.new(orders).adjudicate
      expect(ankara_order.resolution).to eq(Order::FAILED)
      expect(constantinople_order.resolution).to eq(Order::FAILED)
      expect(smyrna_order.resolution).to eq(Order::FAILED)
      expect(bulgaria_order.resolution).to eq(Order::FAILED)
    end

    specify 'C.4. TEST CASE, A CIRCULAR MOVEMENT WITH ATTACKED CONVOY' do
      trieste_army = build_position(nationality: Position::AUSTRIA, area: 'Trieste', unit_type: Position::ARMY)
      trieste_order = build_order(position: trieste_army, order_type: Order::MOVE, area_to: 'Serbia')
      serbia_army = build_position(nationality: Position::AUSTRIA, area: 'Serbia', unit_type: Position::ARMY)
      serbia_order = build_order(position: serbia_army, order_type: Order::MOVE, area_to: 'Bulgaria')
      bulgaria_army = build_position(nationality: Position::TURKEY, area: 'Bulgaria', unit_type: Position::ARMY)
      bulgaria_order = build_order(position: bulgaria_army, order_type: Order::MOVE, area_to: 'Trieste')
      aegean_fleet = build_position(nationality: Position::TURKEY, area: 'Aegean Sea', unit_type: Position::FLEET)
      aegean_order = build_order(position: aegean_fleet, order_type: Order::CONVOY, area_from: 'Bulgaria', area_to: 'Trieste')
      ionian_fleet = build_position(nationality: Position::TURKEY, area: 'Ionian Sea', unit_type: Position::FLEET)
      ionian_order = build_order(position: ionian_fleet, order_type: Order::CONVOY, area_from: 'Bulgaria', area_to: 'Trieste')
      adriatic_fleet = build_position(nationality: Position::TURKEY, area: 'Adriatic Sea', unit_type: Position::FLEET)
      adriatic_order = build_order(position: adriatic_fleet, order_type: Order::CONVOY, area_from: 'Bulgaria', area_to: 'Trieste')
      naples_army = build_position(nationality: Position::ITALY, area: 'Naples', unit_type: Position::FLEET)
      naples_order = build_order(position: naples_army, order_type: Order::MOVE, area_to: 'Ionian Sea')
      orders = [trieste_order, serbia_order, bulgaria_order, aegean_order, ionian_order, adriatic_order, naples_order]

      subject.new(orders).adjudicate
      expect(adriatic_order.resolution).to eq(Order::SUCCEEDED)
      expect(trieste_order.resolution).to eq(Order::SUCCEEDED)
      expect(serbia_order.resolution).to eq(Order::SUCCEEDED)
      expect(bulgaria_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'C.5. TEST CASE, A DISRUPTED CIRCULAR MOVEMENT DUE TO DISLODGED CONVOY' do
      trieste_army = build_position(nationality: Position::AUSTRIA, area: 'Trieste', unit_type: Position::ARMY)
      trieste_order = build_order(position: trieste_army, order_type: Order::MOVE, area_to: 'Serbia')
      serbia_army = build_position(nationality: Position::AUSTRIA, area: 'Serbia', unit_type: Position::ARMY)
      serbia_order = build_order(position: serbia_army, order_type: Order::MOVE, area_to: 'Bulgaria')
      bulgaria_army = build_position(nationality: Position::TURKEY, area: 'Bulgaria', unit_type: Position::ARMY)
      bulgaria_order = build_order(position: bulgaria_army, order_type: Order::MOVE, area_to: 'Trieste')
      aegean_fleet = build_position(nationality: Position::TURKEY, area: 'Aegean Sea', unit_type: Position::FLEET)
      aegean_order = build_order(position: aegean_fleet, order_type: Order::CONVOY, area_from: 'Bulgaria', area_to: 'Trieste')
      ionian_fleet = build_position(nationality: Position::TURKEY, area: 'Ionian Sea', unit_type: Position::FLEET)
      ionian_order = build_order(position: ionian_fleet, order_type: Order::CONVOY, area_from: 'Bulgaria', area_to: 'Trieste')
      adriatic_fleet = build_position(nationality: Position::TURKEY, area: 'Adriatic Sea', unit_type: Position::FLEET)
      adriatic_order = build_order(position: adriatic_fleet, order_type: Order::CONVOY, area_from: 'Bulgaria', area_to: 'Trieste')
      naples_fleet = build_position(nationality: Position::ITALY, area: 'Naples', unit_type: Position::FLEET)
      naples_order = build_order(position: naples_fleet, order_type: Order::MOVE, area_to: 'Ionian Sea')
      tunis_fleet = build_position(nationality: Position::ITALY, area: 'Tunis', unit_type: Position::FLEET)
      tunis_order = build_order(position: tunis_fleet, order_type: Order::SUPPORT, area_from: 'Naples', area_to: 'Ionian Sea')
      orders = [trieste_order, serbia_order, bulgaria_order, aegean_order, ionian_order, adriatic_order, naples_order, tunis_order]

      subject.new(orders).adjudicate
      expect(naples_order.resolution).to eq(Order::SUCCEEDED)
      expect(ionian_order.resolution).to eq(Order::FAILED)
      expect(trieste_order.resolution).to eq(Order::FAILED)
      expect(serbia_order.resolution).to eq(Order::FAILED)
      expect(bulgaria_order.resolution).to eq(Order::FAILED)
    end

    specify 'C.6. TEST CASE, TWO ARMIES WITH TWO CONVOYS' do
      north_sea_fleet = build_position(nationality: Position::ENGLAND, area: 'North Sea', unit_type: Position::FLEET)
      north_sea_order = build_order(position: north_sea_fleet, order_type: Order::CONVOY, area_from: 'London', area_to: 'Belgium')
      london_army = build_position(nationality: Position::ENGLAND, area: 'London', unit_type: Position::ARMY)
      london_order = build_order(position: london_army, order_type: Order::MOVE, area_to: 'Belgium')
      english_channel_fleet = build_position(nationality: Position::FRANCE, area: 'English Channel', unit_type: Position::FLEET)
      english_channel_order = build_order(position: english_channel_fleet, order_type: Order::CONVOY, area_from: 'Belgium', area_to: 'London')
      belgium_army = build_position(nationality: Position::FRANCE, area: 'Belgium', unit_type: Position::ARMY)
      belgium_order = build_order(position: belgium_army, order_type: Order::MOVE, area_to: 'London')
      orders = [north_sea_order, london_order, english_channel_order, belgium_order]

      subject.new(orders).adjudicate
      expect(london_order.resolution).to eq(Order::SUCCEEDED)
      expect(belgium_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'C.7. TEST CASE, DISRUPTED UNIT SWAP' do
      north_sea_fleet = build_position(nationality: Position::ENGLAND, area: 'North Sea', unit_type: Position::FLEET)
      north_sea_order = build_order(position: north_sea_fleet, order_type: Order::CONVOY, area_from: 'London', area_to: 'Belgium')
      london_army = build_position(nationality: Position::ENGLAND, area: 'London', unit_type: Position::ARMY)
      london_order = build_order(position: london_army, order_type: Order::MOVE, area_to: 'Belgium')
      english_channel_fleet = build_position(nationality: Position::FRANCE, area: 'English Channel', unit_type: Position::FLEET)
      english_channel_order = build_order(position: english_channel_fleet, order_type: Order::CONVOY, area_from: 'Belgium', area_to: 'London')
      belgium_army = build_position(nationality: Position::FRANCE, area: 'Belgium', unit_type: Position::ARMY)
      belgium_order = build_order(position: belgium_army, order_type: Order::MOVE, area_to: 'London')
      burgundy_army = build_position(nationality: Position::FRANCE, area: 'Burgundy', unit_type: Position::ARMY)
      burgundy_order = build_order(position: burgundy_army, order_type: Order::MOVE, area_to: 'Belgium')
      orders = [north_sea_order, london_order, english_channel_order, belgium_order, burgundy_order]

      subject.new(orders).adjudicate
      expect(london_order.resolution).to eq(Order::FAILED)
      expect(belgium_order.resolution).to eq(Order::FAILED)
    end
  end
end
