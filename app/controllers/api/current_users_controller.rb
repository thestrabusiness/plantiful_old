module Api
  class CurrentUsersController < Api::BaseController
    skip_before_action :require_login

    def show
      if current_user.present?
        render status: :ok, json: current_user
      else
        head :unauthorized
      end
    end
  end
end
