class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :nationality, null: false
      t.references :game, foreign_key: true, null: false

      t.timestamps
    end

    add_column :positions, :dislodged, :boolean, default: false, null: false
    add_reference :positions, :player, foreign_key: true, null: false
    change_column_null :positions, :nationality, true
  end
end
