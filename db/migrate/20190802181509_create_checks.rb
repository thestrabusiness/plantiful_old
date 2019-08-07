class CreateChecks < ActiveRecord::Migration[5.2]
  def up
    create_table :checks do |t|
      t.timestamp :checked_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.references :plant, index: true, foreign_key: true, null: false
      t.timestamps
    end
  end

  def down
    drop_table :checks
  end
end
