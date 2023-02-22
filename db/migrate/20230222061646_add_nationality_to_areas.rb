class AddNationalityToAreas < ActiveRecord::Migration[7.0]
  def change
    add_column :areas, :nationality, :string
  end
end
