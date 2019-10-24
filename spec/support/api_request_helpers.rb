module ApiRequestHelpers
  def auth_header(user, session_type = 'desktop')
    token = token_for_session_type(user, session_type)
    {
      'HTTP_AUTHORIZATION': "Bearer #{token}",
      "HTTP_SESSION_TYPE": session_type
    }
  end

  private

  def token_for_session_type(user, session_type)
    if session_type == 'mobile'
      user.mobile_api_token
    else
      user.remember_token
    end
  end
end
