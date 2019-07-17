class ApplicationController < ActionController::Base
  include Clearance::Controller
  skip_before_action :verify_authenticity_token
  def index; end
end
