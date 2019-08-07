require './db/migrate/20190624153510_create_waterings.rb'
require './db/migrate/20190802181509_create_checks.rb'

class CreatePlantCareEvents < ActiveRecord::Migration[5.2]
  class Watering < ApplicationRecord; end
  class Check < ApplicationRecord; end
  class PlantCareEvent < ApplicationRecord; end

  def up
    create_table :plant_care_events do |t|
      t.references :plant, index: true, foreign_key: true
      t.timestamp :happened_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.string :kind, null: false
      t.timestamps
    end

    Watering.find_each do |watering|
      PlantCareEvent.create!(happened_at: watering.watered_at, plant_id: watering.plant_id, kind: 'watering')
    end

    Check.find_each do |check|
      PlantCareEvent.create!(happened_at: check.checked_at, plant_id: check.plant_id, kind: 'check')
    end

    drop_table :waterings
    drop_table :checks
  end

  def down
    CreateWaterings.new.up
    CreateChecks.new.up

    PlantCareEvent.find_each do |event|
      if event.kind == 'watering'
        Watering.create!(plant_id: event.plant_id, watered_at: event.happened_at)
      else
        Check.create!(plant_id: event.plant_id, checked_at: event.happened_at)
      end
    end

    drop_table :plant_care_events
  end
end
