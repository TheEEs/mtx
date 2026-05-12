class CreateRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms do |t|
      t.string :name
      t.string :owner
      t.text :description
      t.datetime :valid_from
      t.datetime :valid_to

      t.timestamps
    end
    add_index :rooms, :name
  end
end
