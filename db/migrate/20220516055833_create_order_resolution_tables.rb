class CreateOrderResolutionTables < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.string :nationality, null: false
      t.string :unit_type, null: false
      t.references :area, foreign_key: true, null: false
      t.references :coast, foreign_key: true, null: true

      t.timestamps
    end

    create_table :orders do |t|
      t.references :position, foreign_key: true, null: false
      t.string :order_type, null: false
      t.references :area_from, null: true, foreign_key: { to_table: :areas }
      t.references :area_to, null: true, foreign_key: { to_table: :areas }
      t.references :coast_from, null: true, foreign_key: { to_table: :coasts }
      t.references :coast_to, null: true, foreign_key: { to_table: :coasts }
      t.string :resolution, null: true

      t.timestamps
    end
  end
end
