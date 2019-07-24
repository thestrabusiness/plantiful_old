class Api::UsersController < ApplicationController
  def create
    user = User.new(user_params)

    if user.save
      sign_in user
      render json: user, status: :created
    else
      render json: user.errors, status: :bad_request
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end
end