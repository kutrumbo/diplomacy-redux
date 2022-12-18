class CreateTurns < ActiveRecord::Migration[7.0]
  def change
    create_table :turns do |t|
      t.string :type, null: false
      t.integer :number, null: false
      t.references :game, foreign_key: true, null: false

      t.timestamps
    end

    add_reference :positions, :turn, foreign_key: true
  end
end
