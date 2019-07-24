class Api::PlantsController < ApplicationController
  def index
    render json: Plant.includes(:last_watering)
  end

  def create
    render json: Plant.create(plant_params.merge(user: User.first))
  end

  private

  def plant_params
    params.require(:plant).permit(:name)
  end
end
