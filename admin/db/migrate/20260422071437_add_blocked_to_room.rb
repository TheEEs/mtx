class AddBlockedToRoom < ActiveRecord::Migration[8.1]
  def change
    add_column :rooms, :blocked, :boolean, default: false
  end
end
