class AddStreamIdToRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :stream_id, :string
    add_index :rooms, :stream_id
  end
end
