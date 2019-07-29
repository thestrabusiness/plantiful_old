module ApiRequestHelpers
  def api_sign_in(user)
    cookies['remember_token'] = user.remember_token
  end
end
