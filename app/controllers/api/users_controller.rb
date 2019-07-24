class Api::UsersController < ApplicationController
  def create
    user = User.new(user_params)

    if user.save
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