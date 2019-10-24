class UserSerializer < BaseSerializer
  attributes :id, :default_garden_id, :first_name, :last_name, :email,
             :owned_gardens, :shared_gardens, :remember_token, :mobile_api_token

  def default_garden_id
    object.owned_gardens.first&.id || object.gardens.first&.id
  end

  def shared_gardens
    object.gardens - object.owned_gardens
  end
end
