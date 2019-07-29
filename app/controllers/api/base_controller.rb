class Api::BaseController < ApplicationController
  before_action :require_login

  private

  def deny_access(_)
    head :unauthorized
  end
end
