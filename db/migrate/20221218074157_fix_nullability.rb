class FixNullability < ActiveRecord::Migration[7.0]
  def change
    change_column_null :orders, :order_type, true
    change_column_null :positions, :unit_type, true
    change_column_null :positions, :turn_id, false
  end
end
