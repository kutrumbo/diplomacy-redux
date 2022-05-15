class CreateCoreTables < ActiveRecord::Migration[7.0]
  def change
    create_table :areas do |t|
      t.string :name, null: false
      t.string :area_type, null: false
      t.boolean :supply_center, null: false

      t.index :name, unique: true
      t.timestamps
    end

    create_table :coasts do |t|
      t.references :area, foreign_key: true, null: false
      t.string :direction, null: false

      t.index [:area_id, :direction], unique: true
      t.timestamps
    end

    create_table :borders do |t|
      t.references :area, foreign_key: true, null: false
      t.references :neighbor, foreign_key: { to_table: :areas }, null: false
      t.references :coast, foreign_key: true, null: true, index: false

      t.index [:area_id, :neighbor_id, :coast_id], unique: true
      t.timestamps
    end
  end
end
