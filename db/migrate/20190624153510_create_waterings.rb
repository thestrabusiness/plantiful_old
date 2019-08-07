class CreateWaterings < ActiveRecord::Migration[5.2]
  def up
    create_table :waterings do |t|
      t.references :plant, index: true, null: false
      t.timestamp :watered_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end
  end

  def down
    drop_table :waterings
  end
end
