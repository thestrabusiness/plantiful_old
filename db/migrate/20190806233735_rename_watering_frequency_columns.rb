class RenameWateringFrequencyColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :plants, :watering_frequency_scalar, :check_frequency_scalar
    rename_column :plants, :watering_frequency_unit, :check_frequency_unit
    change_column_default :plants, :check_frequency_scalar, from: 1, to: 3
    change_column_default :plants, :check_frequency_unit, from: 'weeks', to: 'days'
  end
end
