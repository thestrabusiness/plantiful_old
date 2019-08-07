class AddWateringFrequencyToPlants < ActiveRecord::Migration[5.2]
  def change
    add_column :plants, :watering_frequency_scalar, :integer, null: false
    add_column :plants, :watering_frequency_unit, :string, null: false
  end
end
