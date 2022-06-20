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

    specify 'A.5. TEST CASE, MOVE TO OWN SECTOR WITH CONVOY' do
      north_sea_fleet = build_position(nationality: Position::ENGLAND, area: 'North Sea', unit_type: Position::FLEET)
      north_sea_order = build_order(position: north_sea_fleet, order_type: Order::CONVOY, area_from: 'Yorkshire', area_to: 'Yorkshire')
      yorkshire_army = build_position(nationality: Position::ENGLAND, area: 'Yorkshire', unit_type: Position::ARMY)
      yorkshire_order = build_order(position: yorkshire_army, order_type: Order::MOVE, area_to: 'Yorkshire')
      liverpool_army = build_position(nationality: Position::ENGLAND, area: 'Liverpool', unit_type: Position::ARMY)
      liverpool_order = build_order(position: liverpool_army, order_type: Order::SUPPORT, area_from: 'Yorkshire', area_to: 'Yorkshire')
      london_fleet = build_position(nationality: Position::GERMANY, area: 'London', unit_type: Position::FLEET)
      london_order = build_order(position: london_fleet, order_type: Order::MOVE, area_to: 'Yorkshire')
      wales_army = build_position(nationality: Position::GERMANY, area: 'Wales', unit_type: Position::ARMY)
      wales_order = build_order(position: wales_army, order_type: Order::SUPPORT, area_from: 'London', area_to: 'Yorkshire')
      orders = [north_sea_order, yorkshire_order, liverpool_order, london_order, wales_order]

      subject.new(orders).adjudicate
      expect(north_sea_order.resolution).to eq(Order::FAILED)
      expect(yorkshire_order.resolution).to eq(Order::FAILED)
      expect(london_order.resolution).to eq(Order::SUCCEEDED)
    end

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

    specify 'B.6. TEST CASE, SUPPORT CAN BE CUT WITH OTHER COAST' do
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
    specify 'B.8. TEST CASE, SUPPORTING WITH UNSPECIFIED COAST WHEN ONLY ONE COAST IS POSSIBLE'
    # not applicable to order schema
    specify 'B.9. TEST CASE, SUPPORTING WITH WRONG COAST'
    specify 'B.10. TEST CASE, UNIT ORDERED WITH WRONG COAST'
    specify 'B.11. TEST CASE, COAST CAN NOT BE ORDERED TO CHANGE'
    specify 'B.12. TEST CASE, ARMY MOVEMENT WITH COASTAL SPECIFICATION'

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

    specify 'D.1. TEST CASE, SUPPORTED HOLD CAN PREVENT DISLODGEMENT' do
      adriatic_fleet = build_position(nationality: Position::AUSTRIA, area: 'Adriatic Sea', unit_type: Position::FLEET)
      adriatic_order = build_order(position: adriatic_fleet, order_type: Order::SUPPORT, area_from: 'Trieste', area_to: 'Venice')
      trieste_army = build_position(nationality: Position::AUSTRIA, area: 'Trieste', unit_type: Position::ARMY)
      trieste_order = build_order(position: trieste_army, order_type: Order::MOVE, area_to: 'Venice')
      venice_army = build_position(nationality: Position::ITALY, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::HOLD)
      tyrolia_army = build_position(nationality: Position::ITALY, area: 'Tyrolia', unit_type: Position::ARMY)
      tyrolia_order = build_order(position: tyrolia_army, order_type: Order::SUPPORT, area_from: 'Venice', area_to: 'Venice')
      orders = [adriatic_order, trieste_order, venice_order, tyrolia_order]

      subject.new(orders).adjudicate
      expect(trieste_order.resolution).to eq(Order::FAILED)
      expect(venice_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'D.2. TEST CASE, A MOVE CUTS SUPPORT ON HOLD' do
      adriatic_fleet = build_position(nationality: Position::AUSTRIA, area: 'Adriatic Sea', unit_type: Position::FLEET)
      adriatic_order = build_order(position: adriatic_fleet, order_type: Order::SUPPORT, area_from: 'Trieste', area_to: 'Venice')
      trieste_army = build_position(nationality: Position::AUSTRIA, area: 'Trieste', unit_type: Position::ARMY)
      trieste_order = build_order(position: trieste_army, order_type: Order::MOVE, area_to: 'Venice')
      vienna_army = build_position(nationality: Position::AUSTRIA, area: 'Vienna', unit_type: Position::ARMY)
      vienna_order = build_order(position: vienna_army, order_type: Order::MOVE, area_to: 'Tyrolia')
      venice_army = build_position(nationality: Position::ITALY, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::HOLD)
      tyrolia_army = build_position(nationality: Position::ITALY, area: 'Tyrolia', unit_type: Position::ARMY)
      tyrolia_order = build_order(position: tyrolia_army, order_type: Order::SUPPORT, area_from: 'Venice', area_to: 'Venice')
      orders = [adriatic_order, trieste_order, vienna_order, venice_order, tyrolia_order]

      subject.new(orders).adjudicate
      expect(trieste_order.resolution).to eq(Order::SUCCEEDED)
      expect(venice_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.3. TEST CASE, A MOVE CUTS SUPPORT ON MOVE' do
      adriatic_fleet = build_position(nationality: Position::AUSTRIA, area: 'Adriatic Sea', unit_type: Position::FLEET)
      adriatic_order = build_order(position: adriatic_fleet, order_type: Order::SUPPORT, area_from: 'Trieste', area_to: 'Venice')
      trieste_army = build_position(nationality: Position::AUSTRIA, area: 'Trieste', unit_type: Position::ARMY)
      trieste_order = build_order(position: trieste_army, order_type: Order::MOVE, area_to: 'Venice')
      venice_army = build_position(nationality: Position::ITALY, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::HOLD)
      ionian_fleet = build_position(nationality: Position::ITALY, area: 'Ionian Sea', unit_type: Position::FLEET)
      ionian_order = build_order(position: ionian_fleet, order_type: Order::MOVE, area_to: 'Adriatic Sea')
      orders = [adriatic_order, trieste_order, venice_order, ionian_order]

      subject.new(orders).adjudicate
      expect(trieste_order.resolution).to eq(Order::FAILED)
      expect(venice_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'D.4. TEST CASE, SUPPORT TO HOLD ON UNIT SUPPORTING A HOLD ALLOWED' do
      berlin_army = build_position(nationality: Position::GERMANY, area: 'Berlin', unit_type: Position::ARMY)
      berlin_order = build_order(position: berlin_army, order_type: Order::SUPPORT, area_from: 'Kiel', area_to: 'Kiel')
      kiel_army = build_position(nationality: Position::GERMANY, area: 'Kiel', unit_type: Position::ARMY)
      kiel_order = build_order(position: kiel_army, order_type: Order::SUPPORT, area_from: 'Berlin', area_to: 'Berlin')
      baltic_fleet = build_position(nationality: Position::RUSSIA, area: 'Baltic Sea', unit_type: Position::FLEET)
      baltic_order = build_order(position: baltic_fleet, order_type: Order::SUPPORT, area_from: 'Prussia', area_to: 'Berlin')
      prussia_army = build_position(nationality: Position::RUSSIA, area: 'Prussia', unit_type: Position::ARMY)
      prussia_order = build_order(position: prussia_army, order_type: Order::MOVE, area_to: 'Berlin')
      orders = [berlin_order, kiel_order, baltic_order, prussia_order]

      subject.new(orders).adjudicate
      expect(prussia_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.5. TEST CASE, SUPPORT TO HOLD ON UNIT SUPPORTING A MOVE ALLOWED' do
      berlin_army = build_position(nationality: Position::GERMANY, area: 'Berlin', unit_type: Position::ARMY)
      berlin_order = build_order(position: berlin_army, order_type: Order::SUPPORT, area_from: 'Munich', area_to: 'Silesia')
      kiel_army = build_position(nationality: Position::GERMANY, area: 'Kiel', unit_type: Position::ARMY)
      kiel_order = build_order(position: kiel_army, order_type: Order::SUPPORT, area_from: 'Berlin', area_to: 'Berlin')
      munich_army = build_position(nationality: Position::GERMANY, area: 'Munich', unit_type: Position::ARMY)
      munich_order = build_order(position: munich_army, order_type: Order::MOVE, area_to: 'Silesia')
      baltic_fleet = build_position(nationality: Position::RUSSIA, area: 'Baltic Sea', unit_type: Position::FLEET)
      baltic_order = build_order(position: baltic_fleet, order_type: Order::SUPPORT, area_from: 'Prussia', area_to: 'Berlin')
      prussia_army = build_position(nationality: Position::RUSSIA, area: 'Prussia', unit_type: Position::ARMY)
      prussia_order = build_order(position: prussia_army, order_type: Order::MOVE, area_to: 'Berlin')
      orders = [berlin_order, kiel_order, baltic_order, prussia_order]

      subject.new(orders).adjudicate
      expect(prussia_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.6. TEST CASE, SUPPORT TO HOLD ON CONVOYING UNIT ALLOWED' do
      berlin_army = build_position(nationality: Position::GERMANY, area: 'Berlin', unit_type: Position::ARMY)
      berlin_order = build_order(position: berlin_army, order_type: Order::MOVE, area_to: 'Sweden')
      baltic_fleet = build_position(nationality: Position::GERMANY, area: 'Baltic Sea', unit_type: Position::FLEET)
      baltic_order = build_order(position: baltic_fleet, order_type: Order::CONVOY, area_from: 'Berlin', area_to: 'Sweden')
      prussia_fleet = build_position(nationality: Position::GERMANY, area: 'Prussia', unit_type: Position::FLEET)
      prussia_order = build_order(position: prussia_fleet, order_type: Order::SUPPORT, area_from: 'Baltic Sea', area_to: 'Baltic Sea')
      livonia_fleet = build_position(nationality: Position::RUSSIA, area: 'Livonia', unit_type: Position::FLEET)
      livonia_order = build_order(position: livonia_fleet, order_type: Order::MOVE, area_to: 'Baltic Sea')
      bothnia_fleet = build_position(nationality: Position::RUSSIA, area: 'Gulf of Bothnia', unit_type: Position::FLEET)
      bothnia_order = build_order(position: bothnia_fleet, order_type: Order::SUPPORT, area_from: 'Livonia', area_to: 'Baltic Sea')
      orders = [berlin_order, baltic_order, prussia_order, livonia_order, bothnia_order]

      subject.new(orders).adjudicate
      expect(berlin_order.resolution).to eq(Order::SUCCEEDED)
      expect(baltic_order.resolution).to eq(Order::SUCCEEDED)
      expect(livonia_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.7. TEST CASE, SUPPORT TO HOLD ON MOVING UNIT NOT ALLOWED' do
      baltic_fleet = build_position(nationality: Position::GERMANY, area: 'Baltic Sea', unit_type: Position::FLEET)
      baltic_order = build_order(position: baltic_fleet, order_type: Order::MOVE, area_to: 'Sweden')
      prussia_fleet = build_position(nationality: Position::GERMANY, area: 'Prussia', unit_type: Position::FLEET)
      prussia_order = build_order(position: prussia_fleet, order_type: Order::SUPPORT, area_from: 'Baltic Sea', area_to: 'Baltic Sea')
      livonia_fleet = build_position(nationality: Position::RUSSIA, area: 'Livonia', unit_type: Position::FLEET)
      livonia_order = build_order(position: livonia_fleet, order_type: Order::MOVE, area_to: 'Baltic Sea')
      bothnia_fleet = build_position(nationality: Position::RUSSIA, area: 'Gulf of Bothnia', unit_type: Position::FLEET)
      bothnia_order = build_order(position: bothnia_fleet, order_type: Order::SUPPORT, area_from: 'Livonia', area_to: 'Baltic Sea')
      finland_army = build_position(nationality: Position::RUSSIA, area: 'Finland', unit_type: Position::ARMY)
      finland_order = build_order(position: finland_army, order_type: Order::MOVE, area_to: 'Sweden')
      orders = [baltic_order, prussia_order, livonia_order, bothnia_order, finland_order]

      subject.new(orders).adjudicate
      expect(livonia_order.resolution).to eq(Order::SUCCEEDED)
      expect(prussia_order.resolution).to eq(Order::FAILED)
      expect(baltic_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.8. TEST CASE, FAILED CONVOY CAN NOT RECEIVE HOLD SUPPORT' do
      ionian_fleet = build_position(nationality: Position::AUSTRIA, area: 'Ionian Sea', unit_type: Position::FLEET)
      ionian_order = build_order(position: ionian_fleet, order_type: Order::HOLD)
      serbia_army = build_position(nationality: Position::AUSTRIA, area: 'Serbia', unit_type: Position::ARMY)
      serbia_order = build_order(position: serbia_army, order_type: Order::SUPPORT, area_from: 'Albania', area_to: 'Greece')
      albania_army = build_position(nationality: Position::AUSTRIA, area: 'Albania', unit_type: Position::ARMY)
      albania_order = build_order(position: albania_army, order_type: Order::MOVE, area_to: 'Greece')
      greece_army = build_position(nationality: Position::TURKEY, area: 'Greece', unit_type: Position::ARMY)
      greece_order = build_order(position: greece_army, order_type: Order::MOVE, area_to: 'Naples')
      bulgaria_army = build_position(nationality: Position::TURKEY, area: 'Bulgaria', unit_type: Position::ARMY)
      bulgaria_order = build_order(position: bulgaria_army, order_type: Order::SUPPORT, area_from: 'Greece', area_to: 'Greece')
      orders = [ionian_order, serbia_order, albania_order, greece_order, bulgaria_order]

      subject.new(orders).adjudicate
      expect(greece_order.resolution).to eq(Order::FAILED)
      expect(bulgaria_order.resolution).to eq(Order::FAILED)
      expect(albania_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'D.9. TEST CASE, SUPPORT TO MOVE ON HOLDING UNIT NOT ALLOWED' do
      venice_army = build_position(nationality: Position::ITALY, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::MOVE, area_to: 'Trieste')
      tyrolia_army = build_position(nationality: Position::ITALY, area: 'Tyrolia', unit_type: Position::ARMY)
      tyrolia_order = build_order(position: tyrolia_army, order_type: Order::SUPPORT, area_from: 'Venice', area_to: 'Trieste')
      albania_army = build_position(nationality: Position::AUSTRIA, area: 'Albania', unit_type: Position::ARMY)
      albania_order = build_order(position: albania_army, order_type: Order::SUPPORT, area_from: 'Trieste', area_to: 'Serbia')
      trieste_army = build_position(nationality: Position::AUSTRIA, area: 'Trieste', unit_type: Position::ARMY)
      trieste_order = build_order(position: trieste_army, order_type: Order::HOLD)
      orders = [venice_order, tyrolia_order, albania_order, trieste_order]

      subject.new(orders).adjudicate
      expect(venice_order.resolution).to eq(Order::SUCCEEDED)
      expect(trieste_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.10. TEST CASE, SELF DISLODGMENT PROHIBITED' do
      berlin_army = build_position(area: 'Berlin', unit_type: Position::ARMY)
      berlin_order = build_order(position: berlin_army, order_type: Order::HOLD)
      kiel_army = build_position(area: 'Kiel', unit_type: Position::ARMY)
      kiel_order = build_order(position: kiel_army, order_type: Order::MOVE, area_to: 'Berlin')
      munich_army = build_position(area: 'Munich', unit_type: Position::ARMY)
      munich_order = build_order(position: munich_army, order_type: Order::SUPPORT, area_from: 'Kiel', area_to: 'Berlin')
      orders = [berlin_order, kiel_order, munich_order]

      subject.new(orders).adjudicate
      expect(kiel_order.resolution).to eq(Order::FAILED)
      expect(berlin_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'D.11. TEST CASE, NO SELF DISLODGMENT OF RETURNING UNIT' do
      berlin_army = build_position(nationality: Position::GERMANY, area: 'Berlin', unit_type: Position::ARMY)
      berlin_order = build_order(position: berlin_army, order_type: Order::MOVE, area_to: 'Prussia')
      kiel_fleet = build_position(nationality: Position::GERMANY, area: 'Kiel', unit_type: Position::FLEET)
      kiel_order = build_order(position: kiel_fleet, order_type: Order::MOVE, area_to: 'Berlin')
      munich_army = build_position(nationality: Position::GERMANY, area: 'Munich', unit_type: Position::ARMY)
      munich_order = build_order(position: munich_army, order_type: Order::SUPPORT, area_from: 'Kiel', area_to: 'Berlin')
      warsaw_army = build_position(nationality: Position::RUSSIA, area: 'Warsaw', unit_type: Position::ARMY)
      warsaw_order = build_order(position: warsaw_army, order_type: Order::MOVE, area_to: 'Prussia')
      orders = [berlin_order, kiel_order, munich_order, warsaw_order]

      subject.new(orders).adjudicate
      expect(berlin_order.resolution).to eq(Order::FAILED)
      expect(kiel_order.resolution).to eq(Order::FAILED)
      expect(warsaw_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.12. TEST CASE, SUPPORTING A FOREIGN UNIT TO DISLODGE OWN UNIT PROHIBITED' do
      trieste_fleet = build_position(nationality: Position::AUSTRIA, area: 'Trieste', unit_type: Position::FLEET)
      trieste_order = build_order(position: trieste_fleet, order_type: Order::HOLD)
      vienna_army = build_position(nationality: Position::AUSTRIA, area: 'Vienna', unit_type: Position::ARMY)
      vienna_order = build_order(position: vienna_army, order_type: Order::SUPPORT, area_from: 'Venice', area_to: 'Trieste')
      venice_army = build_position(nationality: Position::ITALY, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::MOVE, area_to: 'Trieste')
      orders = [trieste_order, vienna_order, venice_order]

      subject.new(orders).adjudicate
      expect(venice_order.resolution).to eq(Order::FAILED)
      expect(trieste_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'D.13. TEST CASE, SUPPORTING A FOREIGN UNIT TO DISLODGE A RETURNING OWN UNIT PROHIBITED' do
      trieste_fleet = build_position(nationality: Position::AUSTRIA, area: 'Trieste', unit_type: Position::FLEET)
      trieste_order = build_order(position: trieste_fleet, order_type: Order::MOVE, area_to: 'Adriatic Sea')
      vienna_army = build_position(nationality: Position::AUSTRIA, area: 'Vienna', unit_type: Position::ARMY)
      vienna_order = build_order(position: vienna_army, order_type: Order::SUPPORT, area_from: 'Venice', area_to: 'Trieste')
      venice_army = build_position(nationality: Position::ITALY, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::MOVE, area_to: 'Trieste')
      apulia_fleet = build_position(nationality: Position::ITALY, area: 'Apulia', unit_type: Position::FLEET)
      apulia_order = build_order(position: apulia_fleet, order_type: Order::MOVE, area_to: 'Adriatic Sea')
      orders = [trieste_order, vienna_order, venice_order, apulia_order]

      subject.new(orders).adjudicate
      expect(trieste_order.resolution).to eq(Order::FAILED)
      expect(vienna_order.resolution).to eq(Order::SUCCEEDED)
      expect(venice_order.resolution).to eq(Order::FAILED)
      expect(apulia_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.14. TEST CASE, SUPPORTING A FOREIGN UNIT IS NOT ENOUGH TO PREVENT DISLODGEMENT' do
      trieste_fleet = build_position(nationality: Position::AUSTRIA, area: 'Trieste', unit_type: Position::FLEET)
      trieste_order = build_order(position: trieste_fleet, order_type: Order::HOLD)
      vienna_army = build_position(nationality: Position::AUSTRIA, area: 'Vienna', unit_type: Position::ARMY)
      vienna_order = build_order(position: vienna_army, order_type: Order::SUPPORT, area_from: 'Venice', area_to: 'Trieste')
      venice_army = build_position(nationality: Position::ITALY, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::MOVE, area_to: 'Trieste')
      tyrolia_army = build_position(nationality: Position::ITALY, area: 'Tyrolia', unit_type: Position::ARMY)
      tyrolia_order = build_order(position: tyrolia_army, order_type: Order::SUPPORT, area_from: 'Venice', area_to: 'Trieste')
      adriatic_fleet = build_position(nationality: Position::ITALY, area: 'Adriatic Sea', unit_type: Position::FLEET)
      adriatic_order = build_order(position: adriatic_fleet, order_type: Order::SUPPORT, area_from: 'Venice', area_to: 'Trieste')
      orders = [trieste_order, vienna_order, venice_order, tyrolia_order, adriatic_order]

      subject.new(orders).adjudicate
      expect(trieste_order.resolution).to eq(Order::FAILED)
      expect(vienna_order.resolution).to eq(Order::SUCCEEDED)
      expect(venice_order.resolution).to eq(Order::SUCCEEDED)
      expect(tyrolia_order.resolution).to eq(Order::SUCCEEDED)
      expect(adriatic_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'D.15. TEST CASE, DEFENDER CAN NOT CUT SUPPORT FOR ATTACK ON ITSELF' do
      constantinople_fleet = build_position(nationality: Position::RUSSIA, area: 'Constantinople', unit_type: Position::FLEET)
      constantinople_order = build_order(position: constantinople_fleet, order_type: Order::SUPPORT, area_from: 'Black Sea', area_to: 'Ankara')
      black_fleet = build_position(nationality: Position::RUSSIA, area: 'Black Sea', unit_type: Position::FLEET)
      black_order = build_order(position: black_fleet, order_type: Order::MOVE, area_to: 'Ankara')
      ankara_fleet = build_position(nationality: Position::TURKEY, area: 'Ankara', unit_type: Position::FLEET)
      ankara_order = build_order(position: ankara_fleet, order_type: Order::MOVE, area_to: 'Constantinople')
      orders = [constantinople_order, black_order, ankara_order]

      subject.new(orders).adjudicate
      expect(constantinople_order.resolution).to eq(Order::SUCCEEDED)
      expect(black_order.resolution).to eq(Order::SUCCEEDED)
      expect(ankara_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.16. TEST CASE, CONVOYING A UNIT DISLODGING A UNIT OF SAME POWER IS ALLOWED' do
      london_army = build_position(nationality: Position::ENGLAND, area: 'London', unit_type: Position::ARMY)
      london_order = build_order(position: london_army, order_type: Order::HOLD)
      north_sea_fleet = build_position(nationality: Position::ENGLAND, area: 'North Sea', unit_type: Position::FLEET)
      north_sea_order = build_order(position: north_sea_fleet, order_type: Order::CONVOY, area_from: 'Belgium', area_to: 'London')
      english_channel_fleet = build_position(nationality: Position::FRANCE, area: 'English Channel', unit_type: Position::FLEET)
      english_channel_order = build_order(position: english_channel_fleet, order_type: Order::SUPPORT, area_from: 'Belgium', area_to: 'London')
      belgium_army = build_position(nationality: Position::FRANCE, area: 'Belgium', unit_type: Position::ARMY)
      belgium_order = build_order(position: belgium_army, order_type: Order::MOVE, area_to: 'London')
      orders = [london_order, north_sea_order, english_channel_order, belgium_order]

      subject.new(orders).adjudicate
      expect(london_order.resolution).to eq(Order::FAILED)
      expect(north_sea_order.resolution).to eq(Order::SUCCEEDED)
      expect(english_channel_order.resolution).to eq(Order::SUCCEEDED)
      expect(belgium_order.resolution).to eq(Order::SUCCEEDED)
    end

    specify 'D.17. TEST CASE, DISLODGEMENT CUTS SUPPORTS' do
      constantinople_fleet = build_position(nationality: Position::RUSSIA, area: 'Constantinople', unit_type: Position::FLEET)
      constantinople_order = build_order(position: constantinople_fleet, order_type: Order::SUPPORT, area_from: 'Black Sea', area_to: 'Ankara')
      black_sea_fleet = build_position(nationality: Position::RUSSIA, area: 'Black Sea', unit_type: Position::FLEET)
      black_sea_order = build_order(position: black_sea_fleet, order_type: Order::MOVE, area_to: 'Ankara')
      ankara_fleet = build_position(nationality: Position::TURKEY, area: 'Ankara', unit_type: Position::FLEET)
      ankara_order = build_order(position: ankara_fleet, order_type: Order::MOVE, area_to: 'Constantinople')
      smyrna_army = build_position(nationality: Position::TURKEY, area: 'Smyrna', unit_type: Position::ARMY)
      smyrna_order = build_order(position: smyrna_army, order_type: Order::SUPPORT, area_from: 'Ankara', area_to: 'Constantinople')
      armenia_army = build_position(nationality: Position::TURKEY, area: 'Armenia', unit_type: Position::ARMY)
      armenia_order = build_order(position: armenia_army, order_type: Order::MOVE, area_to: 'Ankara')
      orders = [constantinople_order, black_sea_order, ankara_order, smyrna_order, armenia_order]

      subject.new(orders).adjudicate
      expect(constantinople_order.resolution).to eq(Order::FAILED)
      expect(black_sea_order.resolution).to eq(Order::FAILED)
      expect(ankara_order.resolution).to eq(Order::SUCCEEDED)
      expect(smyrna_order.resolution).to eq(Order::SUCCEEDED)
      expect(armenia_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.18. TEST CASE, A SURVIVING UNIT WILL SUSTAIN SUPPORT' do
      constantinople_fleet = build_position(nationality: Position::RUSSIA, area: 'Constantinople', unit_type: Position::FLEET)
      constantinople_order = build_order(position: constantinople_fleet, order_type: Order::SUPPORT, area_from: 'Black Sea', area_to: 'Ankara')
      black_sea_fleet = build_position(nationality: Position::RUSSIA, area: 'Black Sea', unit_type: Position::FLEET)
      black_sea_order = build_order(position: black_sea_fleet, order_type: Order::MOVE, area_to: 'Ankara')
      bulgaria_army = build_position(nationality: Position::RUSSIA, area: 'Bulgaria', unit_type: Position::ARMY)
      bulgaria_order = build_order(position: bulgaria_army, order_type: Order::SUPPORT, area_from: 'Constantinople', area_to: 'Constantinople')
      ankara_fleet = build_position(nationality: Position::TURKEY, area: 'Ankara', unit_type: Position::FLEET)
      ankara_order = build_order(position: ankara_fleet, order_type: Order::MOVE, area_to: 'Constantinople')
      smyrna_army = build_position(nationality: Position::TURKEY, area: 'Smyrna', unit_type: Position::ARMY)
      smyrna_order = build_order(position: smyrna_army, order_type: Order::SUPPORT, area_from: 'Ankara', area_to: 'Constantinople')
      armenia_army = build_position(nationality: Position::TURKEY, area: 'Armenia', unit_type: Position::ARMY)
      armenia_order = build_order(position: armenia_army, order_type: Order::MOVE, area_to: 'Ankara')
      orders = [constantinople_order, black_sea_order, bulgaria_order, ankara_order, smyrna_order, armenia_order]

      subject.new(orders).adjudicate
      expect(constantinople_order.resolution).to eq(Order::SUCCEEDED)
      expect(black_sea_order.resolution).to eq(Order::SUCCEEDED)
      expect(bulgaria_order.resolution).to eq(Order::SUCCEEDED)
      expect(ankara_order.resolution).to eq(Order::FAILED)
      expect(smyrna_order.resolution).to eq(Order::SUCCEEDED)
      expect(armenia_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.19. TEST CASE, EVEN WHEN SURVIVING IS IN ALTERNATIVE WAY' do
      constantinople_fleet = build_position(nationality: Position::RUSSIA, area: 'Constantinople', unit_type: Position::FLEET)
      constantinople_order = build_order(position: constantinople_fleet, order_type: Order::SUPPORT, area_from: 'Black Sea', area_to: 'Ankara')
      black_sea_fleet = build_position(nationality: Position::RUSSIA, area: 'Black Sea', unit_type: Position::FLEET)
      black_sea_order = build_order(position: black_sea_fleet, order_type: Order::MOVE, area_to: 'Ankara')
      bulgaria_army = build_position(nationality: Position::RUSSIA, area: 'Bulgaria', unit_type: Position::ARMY)
      bulgaria_order = build_order(position: bulgaria_army, order_type: Order::SUPPORT, area_from: 'Constantinople', area_to: 'Constantinople')
      ankara_fleet = build_position(nationality: Position::TURKEY, area: 'Ankara', unit_type: Position::FLEET)
      ankara_order = build_order(position: ankara_fleet, order_type: Order::MOVE, area_to: 'Constantinople')
      orders = [constantinople_order, black_sea_order, bulgaria_order, ankara_order]

      subject.new(orders).adjudicate
      expect(constantinople_order.resolution).to eq(Order::SUCCEEDED)
      expect(black_sea_order.resolution).to eq(Order::SUCCEEDED)
      expect(bulgaria_order.resolution).to eq(Order::SUCCEEDED)
      expect(ankara_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.20. TEST CASE, UNIT CAN NOT CUT SUPPORT OF ITS OWN COUNTRY' do
      london_fleet = build_position(nationality: Position::ENGLAND, area: 'London', unit_type: Position::FLEET)
      london_order = build_order(position: london_fleet, order_type: Order::SUPPORT, area_from: 'North Sea', area_to: 'English Channel')
      north_sea_fleet = build_position(nationality: Position::ENGLAND, area: 'North Sea', unit_type: Position::FLEET)
      north_sea_order = build_order(position: north_sea_fleet, order_type: Order::MOVE, area_to: 'English Channel')
      yorkshire_army = build_position(nationality: Position::ENGLAND, area: 'Yorkshire', unit_type: Position::ARMY)
      yorkshire_order = build_order(position: yorkshire_army, order_type: Order::MOVE, area_to: 'London')
      english_channel_fleet = build_position(nationality: Position::FRANCE, area: 'English Channel', unit_type: Position::FLEET)
      english_channel_order = build_order(position: english_channel_fleet, order_type: Order::HOLD)
      orders = [london_order, north_sea_order, yorkshire_order, english_channel_order]

      subject.new(orders).adjudicate
      expect(london_order.resolution).to eq(Order::SUCCEEDED)
      expect(north_sea_order.resolution).to eq(Order::SUCCEEDED)
      expect(yorkshire_order.resolution).to eq(Order::FAILED)
      expect(english_channel_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.21. TEST CASE, DISLODGING DOES NOT CANCEL A SUPPORT CUT' do
      trieste_fleet = build_position(nationality: Position::AUSTRIA, area: 'Trieste', unit_type: Position::FLEET)
      trieste_order = build_order(position: trieste_fleet, order_type: Order::HOLD)
      venice_army = build_position(nationality: Position::ITALY, area: 'Venice', unit_type: Position::ARMY)
      venice_order = build_order(position: venice_army, order_type: Order::MOVE, area_to: 'Trieste')
      tyrolia_army = build_position(nationality: Position::ITALY, area: 'Tyrolia', unit_type: Position::ARMY)
      tyrolia_order = build_order(position: tyrolia_army, order_type: Order::SUPPORT, area_from: 'Venice', area_to: 'Trieste')
      munich_army = build_position(nationality: Position::GERMANY, area: 'Munich', unit_type: Position::ARMY)
      munich_order = build_order(position: munich_army, order_type: Order::MOVE, area_to: 'Tyrolia')
      silesia_army = build_position(nationality: Position::RUSSIA, area: 'Silesia', unit_type: Position::ARMY)
      silesia_order = build_order(position: silesia_army, order_type: Order::MOVE, area_to: 'Munich')
      berlin_army = build_position(nationality: Position::RUSSIA, area: 'Berlin', unit_type: Position::ARMY)
      berlin_order = build_order(position: berlin_army, order_type: Order::SUPPORT, area_from: 'Silesia', area_to: 'Munich')
      orders = [trieste_order, venice_order, tyrolia_order, munich_order, silesia_order, berlin_order]

      subject.new(orders).adjudicate
      expect(trieste_order.resolution).to eq(Order::SUCCEEDED)
      expect(venice_order.resolution).to eq(Order::FAILED)
      expect(tyrolia_order.resolution).to eq(Order::FAILED)
      expect(munich_order.resolution).to eq(Order::FAILED)
      expect(silesia_order.resolution).to eq(Order::SUCCEEDED)
      expect(berlin_order.resolution).to eq(Order::SUCCEEDED)
    end

    # prevented at order level
    specify 'D.22. TEST CASE, IMPOSSIBLE FLEET MOVE CAN NOT BE SUPPORTED'
    specify 'D.23 TEST CASE, IMPOSSIBLE COAST MOVE CAN NOT BE SUPPORTED'
    specify 'D.24. TEST CASE, IMPOSSIBLE ARMY MOVE CAN NOT BE SUPPORTED'

    specify 'D.25. TEST CASE, FAILING HOLD SUPPORT CAN BE SUPPORTED' do
      berlin_army = build_position(nationality: Position::GERMANY, area: 'Berlin', unit_type: Position::ARMY)
      berlin_order = build_order(position: berlin_army, order_type: Order::SUPPORT, area_from: 'Prussia', area_to: 'Prussia')
      kiel_fleet = build_position(nationality: Position::GERMANY, area: 'Kiel', unit_type: Position::FLEET)
      kiel_order = build_order(position: kiel_fleet, order_type: Order::SUPPORT, area_from: 'Berlin', area_to: 'Berlin')
      baltic_fleet = build_position(nationality: Position::RUSSIA, area: 'Baltic Sea', unit_type: Position::FLEET)
      baltic_order = build_order(position: baltic_fleet, order_type: Order::SUPPORT, area_from: 'Prussia', area_to: 'Berlin')
      prussia_army = build_position(nationality: Position::RUSSIA, area: 'Prussia', unit_type: Position::ARMY)
      prussia_order = build_order(position: prussia_army, order_type: Order::MOVE, area_to: 'Berlin')
      orders = [berlin_order, kiel_order, baltic_order, prussia_order]

      subject.new(orders).adjudicate
      expect(berlin_order.resolution).to eq(Order::FAILED)
      expect(kiel_order.resolution).to eq(Order::SUCCEEDED)
      expect(baltic_order.resolution).to eq(Order::SUCCEEDED)
      expect(prussia_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.26. TEST CASE, FAILING MOVE SUPPORT CAN BE SUPPORTED' do
      berlin_army = build_position(nationality: Position::GERMANY, area: 'Berlin', unit_type: Position::ARMY)
      berlin_order = build_order(position: berlin_army, order_type: Order::SUPPORT, area_from: 'Prussia', area_to: 'Silesia')
      kiel_fleet = build_position(nationality: Position::GERMANY, area: 'Kiel', unit_type: Position::FLEET)
      kiel_order = build_order(position: kiel_fleet, order_type: Order::SUPPORT, area_from: 'Berlin', area_to: 'Berlin')
      baltic_fleet = build_position(nationality: Position::RUSSIA, area: 'Baltic Sea', unit_type: Position::FLEET)
      baltic_order = build_order(position: baltic_fleet, order_type: Order::SUPPORT, area_from: 'Prussia', area_to: 'Berlin')
      prussia_army = build_position(nationality: Position::RUSSIA, area: 'Prussia', unit_type: Position::ARMY)
      prussia_order = build_order(position: prussia_army, order_type: Order::MOVE, area_to: 'Berlin')
      orders = [berlin_order, kiel_order, baltic_order, prussia_order]

      subject.new(orders).adjudicate
      expect(berlin_order.resolution).to eq(Order::FAILED)
      expect(kiel_order.resolution).to eq(Order::SUCCEEDED)
      expect(baltic_order.resolution).to eq(Order::SUCCEEDED)
      expect(prussia_order.resolution).to eq(Order::FAILED)
    end

    specify 'D.27. TEST CASE, FAILING CONVOY CAN BE SUPPORTED' do
      sweden_fleet = build_position(nationality: Position::ENGLAND, area: 'Sweden', unit_type: Position::FLEET)
      sweden_order = build_order(position: sweden_fleet, order_type: Order::MOVE, area_to: 'Baltic Sea')
      denmark_fleet = build_position(nationality: Position::ENGLAND, area: 'Denmark', unit_type: Position::FLEET)
      denmark_order = build_order(position: denmark_fleet, order_type: Order::SUPPORT, area_from: 'Sweden', area_to: 'Baltic Sea')
      berlin_army = build_position(nationality: Position::GERMANY, area: 'Berlin', unit_type: Position::ARMY)
      berlin_order = build_order(position: berlin_army, order_type: Order::HOLD)
      baltic_fleet = build_position(nationality: Position::RUSSIA, area: 'Baltic Sea', unit_type: Position::FLEET)
      baltic_order = build_order(position: baltic_fleet, order_type: Order::CONVOY, area_from: 'Berlin', area_to: 'Livonia')
      prussia_fleet = build_position(nationality: Position::RUSSIA, area: 'Prussia', unit_type: Position::FLEET)
      prussia_order = build_order(position: prussia_fleet, order_type: Order::SUPPORT, area_from: 'Baltic Sea', area_to: 'Baltic Sea')
      orders = [sweden_order, denmark_order, berlin_order, baltic_order, prussia_order]

      subject.new(orders).adjudicate
      expect(sweden_order.resolution).to eq(Order::FAILED)
      expect(denmark_order.resolution).to eq(Order::SUCCEEDED)
      expect(berlin_order.resolution).to eq(Order::SUCCEEDED)
      expect(baltic_order.resolution).to eq(Order::FAILED)
      expect(prussia_order.resolution).to eq(Order::SUCCEEDED)
    end

    # prevented at order level
    specify 'D.28. TEST CASE, IMPOSSIBLE MOVE AND SUPPORT'
    specify 'D.29. TEST CASE, MOVE TO IMPOSSIBLE COAST AND SUPPORT'
    specify 'D.30. TEST CASE, MOVE WITHOUT COAST AND SUPPORT'

    specify 'D.31. TEST CASE, A TRICKY IMPOSSIBLE SUPPORT' do
      rumania_army = build_position(nationality: Position::AUSTRIA, area: 'Rumania', unit_type: Position::ARMY)
      rumania_order = build_order(position: rumania_army, order_type: Order::MOVE, area_to: 'Armenia')
      black_sea_fleet = build_position(nationality: Position::TURKEY, area: 'Black Sea', unit_type: Position::FLEET)
      black_sea_order = build_order(position: black_sea_fleet, order_type: Order::SUPPORT, area_from: 'Rumania', area_to: 'Armenia')
      orders = [rumania_order, black_sea_order]

      subject.new(orders).adjudicate
      expect(rumania_order.resolution).to eq(Order::FAILED)
    end

    # prevented at order level
    specify 'D.32. TEST CASE, A MISSING FLEET'

    specify 'D.33. TEST CASE, UNWANTED SUPPORT ALLOWED' do
      serbia_army = build_position(nationality: Position::AUSTRIA, area: 'Serbia', unit_type: Position::ARMY)
      serbia_order = build_order(position: serbia_army, order_type: Order::MOVE, area_to: 'Budapest')
      vienna_army = build_position(nationality: Position::AUSTRIA, area: 'Vienna', unit_type: Position::ARMY)
      vienna_order = build_order(position: vienna_army, order_type: Order::MOVE, area_to: 'Budapest')
      galicia_army = build_position(nationality: Position::RUSSIA, area: 'Galicia', unit_type: Position::ARMY)
      galicia_order = build_order(position: galicia_army, order_type: Order::SUPPORT, area_from: 'Serbia', area_to: 'Budapest')
      bulgaria_army = build_position(nationality: Position::TURKEY, area: 'Bulgaria', unit_type: Position::ARMY)
      bulgaria_order = build_order(position: bulgaria_army, order_type: Order::MOVE, area_to: 'Serbia')
      orders = [serbia_order, vienna_order, galicia_order, bulgaria_order]

      subject.new(orders).adjudicate
      expect(serbia_order.resolution).to eq(Order::SUCCEEDED)
      expect(vienna_order.resolution).to eq(Order::FAILED)
      expect(galicia_order.resolution).to eq(Order::SUCCEEDED)
      expect(bulgaria_order.resolution).to eq(Order::SUCCEEDED)
    end

    # prevented at order level
    specify 'D.34. TEST CASE, SUPPORT TARGETING OWN AREA NOT ALLOWED'

    specify 'E.1. TEST CASE, DISLODGED UNIT HAS NO EFFECT ON ATTACKERS AREA'
  end
end
