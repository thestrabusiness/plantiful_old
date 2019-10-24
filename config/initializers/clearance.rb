Clearance.configure do |config|
  config.mailer_sender = "reply@example.com"
  config.rotate_csrf_on_sign_in = false
  config.routes = false
end

module Clearance
  class Session
    def remember_token
      pattern = /^Bearer /
      header = @env['HTTP_AUTHORIZATION']
      header.gsub(pattern, '') if header&.match(pattern)
    end

    def current_user
      if remember_token.present?
        @current_user ||= user_from_session_type
      end

      @current_user
    end

    def sign_out
      if signed_in?
        if session_type == 'desktop'
          current_user.reset_remember_token!
        elsif session_type =='mobile'
          current_user.reset_mobile_api_token!
        end
      end

      @current_user = nil
      cookies.delete remember_token_cookie
    end

    private 

    def user_from_session_type
      case session_type
      when 'mobile'
        user_from_mobile_api_token(remember_token)
      when 'desktop'
        user_from_remember_token(remember_token)
      else
        nil
      end
    end

    def user_from_mobile_api_token(remember_token)
      Clearance
        .configuration
        .user_model
        .where(mobile_api_token: remember_token)
        .first
    end

    def session_type
      @env['HTTP_SESSION_TYPE']
    end
  end
end
