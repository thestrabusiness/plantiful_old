module Api
  class UsersController < Api::BaseController
    skip_before_action :require_login

    def create
      user = User.new(user_params)
      garden = Garden.new(name: user.default_garden_name, owner: user)

      if user.save && garden.save
        sign_in user
        render_with_status(user, :created)
      else
        render_with_status(user.errors, :unprocessable_entity)
      end
    end

    private

    def render_with_status(response, status)
      render json: response, status: status
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end
  end
end
