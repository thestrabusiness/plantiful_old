class AddDeletedAtToPlants < ActiveRecord::Migration[5.2]
  def change
    add_column :plants, :deleted_at, :timestamp
  end
end
