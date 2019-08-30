class CreateCheckIns < ActiveRecord::Migration[5.2]
  class PlantCareEvent < ApplicationRecord
    belongs_to :plant
  end

  class CheckIn < ApplicationRecord
    belongs_to :plant
  end

  def up
    create_table :check_ins do |t|
      t.references :plant, foreign_key: true, index: true, null: false
      t.string :notes
      t.boolean :watered, default: false, null: false, index: true
      t.boolean :fertilized, default: false, null: false, index: true

      t.timestamps
      t.index [:watered, :fertilized]
    end

    PlantCareEvent.find_each do |event| 
      CheckIn.create!(watered: true, plant: event.plant)
    end

    drop_table :plant_care_events
  end

  def down
    create_table :plant_care_events do |t|
      t.references :plant, index: true, foreign_key: true
      t.timestamp :happened_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.string :kind, null: false
      t.timestamps
    end

    CheckIn.find_each do |check_in|
      PlantCareEvent.create!(kind: 'watering', plant: check_in.plant)
    end

    drop_table :check_ins
  end
end
