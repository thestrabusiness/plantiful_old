class UsersGardensManyToMany < ActiveRecord::Migration[5.2]
  class Garden < ApplicationRecord
    has_and_belongs_to_many :users
  end

  class User < ApplicationRecord
    belongs_to :garden
  end

  def up
    create_table :gardens_users do |t|
      t.timestamps
      t.references :user, index: true, foreign_key: true, null: false
      t.references :garden, index: true, foreign_key: true, null: false
    end

    add_reference :gardens, :owner, index: true, foreign_key: { to_table: :users }

    User.find_each do |user|
      garden = user.garden
      if garden.owner_id.nil?
        garden.update(owner_id: user.id)
        garden.users << User.where(garden_id: garden.id)
      end
    end

    change_column_null :gardens, :owner_id, false
    remove_reference :users, :garden
  end

  def down
    add_reference :users, :garden, index: true, foreign_key: true

    Garden.find_each do |garden|
      User.find(garden.owner_id).update(garden_id: garden.id)
      garden.users.update_all(garden_id: garden.id)
    end

    change_column_null :users, :garden_id, false
    remove_reference :gardens, :owner
    drop_table :gardens_users
  end
end
