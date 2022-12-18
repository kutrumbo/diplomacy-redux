module GameService
  def self.initialize_game!(name)
    ActiveRecord::Base.transaction do
      game = Game.create!(name: name)
      turn = game.turns.create!(number: 1, type: Turn::SPRING)

      turn.positions.create!(nationality: Position::AUSTRIA, area: Area.find_by_name('Vienna'), unit_type: Position::ARMY)
      turn.positions.create!(nationality: Position::AUSTRIA, area: Area.find_by_name('Budapest'), unit_type: Position::ARMY)
      turn.positions.create!(nationality: Position::AUSTRIA, area: Area.find_by_name('Trieste'), unit_type: Position::FLEET)

      turn.positions.create!(nationality: Position::ENGLAND, area: Area.find_by_name('Edinburgh'), unit_type: Position::FLEET)
      turn.positions.create!(nationality: Position::ENGLAND, area: Area.find_by_name('Liverpool'), unit_type: Position::ARMY)
      turn.positions.create!(nationality: Position::ENGLAND, area: Area.find_by_name('London'), unit_type: Position::FLEET)

      turn.positions.create!(nationality: Position::FRANCE, area: Area.find_by_name('Brest'), unit_type: Position::FLEET)
      turn.positions.create!(nationality: Position::FRANCE, area: Area.find_by_name('Paris'), unit_type: Position::ARMY)
      turn.positions.create!(nationality: Position::FRANCE, area: Area.find_by_name('Marseilles'), unit_type: Position::ARMY)

      turn.positions.create!(nationality: Position::GERMANY, area: Area.find_by_name('Kiel'), unit_type: Position::FLEET)
      turn.positions.create!(nationality: Position::GERMANY, area: Area.find_by_name('Berlin'), unit_type: Position::ARMY)
      turn.positions.create!(nationality: Position::GERMANY, area: Area.find_by_name('Munich'), unit_type: Position::ARMY)

      turn.positions.create!(nationality: Position::ITALY, area: Area.find_by_name('Venice'), unit_type: Position::ARMY)
      turn.positions.create!(nationality: Position::ITALY, area: Area.find_by_name('Rome'), unit_type: Position::ARMY)
      turn.positions.create!(nationality: Position::ITALY, area: Area.find_by_name('Naples'), unit_type: Position::FLEET)

      saint_petersburg = Area.find_by_name('Saint Petersburg')
      turn.positions.create!(nationality: Position::RUSSIA, area: saint_petersburg, coast: saint_petersburg.coasts.find_by(direction: 'south'), unit_type: Position::FLEET)
      turn.positions.create!(nationality: Position::RUSSIA, area: Area.find_by_name('Moscow'), unit_type: Position::ARMY)
      turn.positions.create!(nationality: Position::RUSSIA, area: Area.find_by_name('Warsaw'), unit_type: Position::ARMY)
      turn.positions.create!(nationality: Position::RUSSIA, area: Area.find_by_name('Sevastopol'), unit_type: Position::FLEET)

      turn.positions.create!(nationality: Position::TURKEY, area: Area.find_by_name('Constantinople'), unit_type: Position::ARMY)
      turn.positions.create!(nationality: Position::TURKEY, area: Area.find_by_name('Ankara'), unit_type: Position::FLEET)
      turn.positions.create!(nationality: Position::TURKEY, area: Area.find_by_name('Smyrna'), unit_type: Position::ARMY)

      turn.positions.each { |p| Order.create!(position: p) }
      game.reload
    end
  end
end
