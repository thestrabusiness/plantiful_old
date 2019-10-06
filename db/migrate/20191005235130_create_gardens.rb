class CreateGardens < ActiveRecord::Migration[5.2]
  class User < ApplicationRecord
    has_many :plants
  end

  class Plant < ApplicationRecord
    belongs_to :user
    has_many :check_ins
  end

  def up
    create_table :gardens do |t|
      t.timestamps
      t.string :name, null: false
    end

    add_reference :users, :garden, index: true, foreign_key: true
    add_reference :check_ins, :performed_by, foreign_key: { to_table: :users }, index: true
    add_reference :plants, :added_by, foreign_key: { to_table: :users }, index: true
    add_reference :plants, :garden,  index: true

    User.find_each do |user|
      garden = Garden.create!(name: "#{user.first_name}'s Garden")
      user.update(garden_id: garden.id)
      plants = user.plants
      plants.update_all(added_by_id: user.id, garden_id: garden.id)
      plants.each do |plant|
        plant.check_ins.update_all(performed_by_id: user.id)
      end
    end

    change_column_null :users, :garden_id, false
    remove_reference :plants, :user
    change_column_null :plants, :added_by_id, false
    change_column_null :plants, :garden_id, false
    change_column_null :check_ins, :performed_by_id, false
  end

  def down
    add_reference :plants, :user, foreign_key: true, index: true

    Plant.update_all("user_id = added_by_id")

    change_column_null :plants, :user_id, false
    remove_reference :check_ins, :performed_by
    remove_reference :plants, :added_by
    remove_reference :plants, :garden
    remove_reference :users, :garden
    drop_table :gardens
  end
end
