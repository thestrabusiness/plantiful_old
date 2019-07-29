class Api::PlantsController < Api::BaseController
  def index
    render json: current_user.plants.includes(:last_watering)
  end

  def create
    render json: current_user.plants.create(plant_params)
  end

  private

  def plant_params
    params.require(:plant).permit(:name)
  end
end
