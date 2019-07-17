class CreateUsers < ActiveRecord::Migration[5.2]
  def up
    create_table :users do |t|
      t.timestamps null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, unique: true
      t.string :encrypted_password, limit: 128, null: false
      t.string :confirmation_token, limit: 128
      t.string :remember_token, limit: 128, null: false
    end

    add_index :users, :email
    add_index :users, :remember_token

    add_reference :plants, :user, foreign_key: true
  end

  def down
    drop_table :users
    remove_column :plants, :user_id
  end
end
