module GameService
  def self.initialize_game!(name)
    ActiveRecord::Base.transaction do
      game = Game.create!(name: name)
      turn = game.turns.create!(number: 1, type: Turn::SPRING)

      austria = Player.create!(game: game, nationality: Position::AUSTRIA)
      turn.positions.create!(nationality: Position::AUSTRIA, area: Area.find_by_name('Vienna'), unit_type: Position::ARMY, player: austria)
      turn.positions.create!(nationality: Position::AUSTRIA, area: Area.find_by_name('Budapest'), unit_type: Position::ARMY, player: austria)
      turn.positions.create!(nationality: Position::AUSTRIA, area: Area.find_by_name('Trieste'), unit_type: Position::FLEET, player: austria)

      england = Player.create!(game: game, nationality: Position::ENGLAND)
      turn.positions.create!(nationality: Position::ENGLAND, area: Area.find_by_name('Edinburgh'), unit_type: Position::FLEET, player: england)
      turn.positions.create!(nationality: Position::ENGLAND, area: Area.find_by_name('Liverpool'), unit_type: Position::ARMY, player: england)
      turn.positions.create!(nationality: Position::ENGLAND, area: Area.find_by_name('London'), unit_type: Position::FLEET, player: england)

      france = Player.create!(game: game, nationality: Position::FRANCE)
      turn.positions.create!(nationality: Position::FRANCE, area: Area.find_by_name('Brest'), unit_type: Position::FLEET, player: france)
      turn.positions.create!(nationality: Position::FRANCE, area: Area.find_by_name('Paris'), unit_type: Position::ARMY, player: france)
      turn.positions.create!(nationality: Position::FRANCE, area: Area.find_by_name('Marseilles'), unit_type: Position::ARMY, player: france)

      germany = Player.create!(game: game, nationality: Position::GERMANY)
      turn.positions.create!(nationality: Position::GERMANY, area: Area.find_by_name('Kiel'), unit_type: Position::FLEET, player: germany)
      turn.positions.create!(nationality: Position::GERMANY, area: Area.find_by_name('Berlin'), unit_type: Position::ARMY, player: germany)
      turn.positions.create!(nationality: Position::GERMANY, area: Area.find_by_name('Munich'), unit_type: Position::ARMY, player: germany)

      italy = Player.create!(game: game, nationality: Position::ITALY)
      turn.positions.create!(nationality: Position::ITALY, area: Area.find_by_name('Venice'), unit_type: Position::ARMY, player: italy)
      turn.positions.create!(nationality: Position::ITALY, area: Area.find_by_name('Rome'), unit_type: Position::ARMY, player: italy)
      turn.positions.create!(nationality: Position::ITALY, area: Area.find_by_name('Naples'), unit_type: Position::FLEET, player: italy)

      russia = Player.create!(game: game, nationality: Position::RUSSIA)
      saint_petersburg = Area.find_by_name('Saint Petersburg')
      turn.positions.create!(nationality: Position::RUSSIA, area: saint_petersburg, coast: saint_petersburg.coasts.find_by(direction: 'south'), unit_type: Position::FLEET, player: russia)
      turn.positions.create!(nationality: Position::RUSSIA, area: Area.find_by_name('Moscow'), unit_type: Position::ARMY, player: russia)
      turn.positions.create!(nationality: Position::RUSSIA, area: Area.find_by_name('Warsaw'), unit_type: Position::ARMY, player: russia)
      turn.positions.create!(nationality: Position::RUSSIA, area: Area.find_by_name('Sevastopol'), unit_type: Position::FLEET, player: russia)

      turkey = Player.create!(game: game, nationality: Position::TURKEY)
      turn.positions.create!(nationality: Position::TURKEY, area: Area.find_by_name('Constantinople'), unit_type: Position::ARMY, player: turkey)
      turn.positions.create!(nationality: Position::TURKEY, area: Area.find_by_name('Ankara'), unit_type: Position::FLEET, player: turkey)
      turn.positions.create!(nationality: Position::TURKEY, area: Area.find_by_name('Smyrna'), unit_type: Position::ARMY, player: turkey)

      turn.positions.each { |p| Order.create!(position: p) }
      game.reload
    end
  end
end
