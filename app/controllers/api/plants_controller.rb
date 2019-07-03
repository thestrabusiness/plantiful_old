class Api::PlantsController < ApplicationController
  def index
    render json: Plant.includes(:last_watering)
  end
end
