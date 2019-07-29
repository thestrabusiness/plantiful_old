class Api::CurrentUsersController < Api::BaseController
  skip_before_action :require_login

  def show
    render json: current_user
  end
end
