class AddTimeZoneToRoom < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :timezone, :string
  end
end
