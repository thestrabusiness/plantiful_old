class AddApiTokenToUser < ActiveRecord::Migration[5.2]
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  def change
    add_column :users,
      :mobile_api_token,
      :uuid,
      default: "gen_random_uuid()",
      null: false

    add_index :users, :mobile_api_token, unique: true
  end
end
