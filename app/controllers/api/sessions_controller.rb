class Api::SessionsController < Api::BaseController
  skip_before_action :require_login, only: :create

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

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
