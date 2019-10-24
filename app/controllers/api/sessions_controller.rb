module Api
  class SessionsController < Api::BaseController
    skip_before_action :require_login, only: :create
    skip_before_action :require_login, only: :status, unless: :mobile_session?

    def create
      user = User.authenticate(user_params[:email], user_params[:password])

      if user.present?
        sign_in user
        render json: user, status: :ok
      else
        head :unauthorized
      end
    end

    def destroy
      sign_out
      head :ok
    end

    def status
      if remember_token.present?
        render json: User.find_by(remember_token: remember_token), status: :ok
      else
        head :unauthorized
      end
    end

    private

    def remember_token
      cookies[remember_token_cookie]
    end

    def remember_token_cookie
      Clearance.configuration.cookie_name.freeze
    end

    def user_params
      params.require(:user).permit(:email, :password)
    end
  end
end
