module ApiRequestHelpers
  def auth_header(user)
    { 'HTTP_AUTHORIZATION': "Bearer #{user.remember_token}" }
  end
end
