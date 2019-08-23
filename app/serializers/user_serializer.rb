class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :remember_token
end
