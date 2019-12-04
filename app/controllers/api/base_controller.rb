module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token, if: :mobile_session?
    before_action :require_login

    rescue_from ActiveRecord::RecordNotFound do
      head :not_found
    end

    private

    def deny_access(_)
      head :unauthorized
    end

    def mobile_session?
      request.env['HTTP_SESSION_TYPE'] == 'mobile'
    end
  end
end
