class UserSerializer < BaseSerializer
  attributes :id, :default_garden_id, :first_name, :last_name, :email,
             :remember_token

  def default_garden_id
    object.owned_gardens.first&.id || object.gardens.first.id
  end
end
