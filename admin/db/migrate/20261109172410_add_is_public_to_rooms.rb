class AddIsPublicToRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :is_public, :boolean, default: true, null: false
  end
end
