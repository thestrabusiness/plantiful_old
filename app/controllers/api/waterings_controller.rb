class Api::WateringsController < Api::BaseController
  def create
    plant = current_user.plants.find(params[:plant_id])
    if plant.waterings.create
      render json: plant, status: :created
    else
      head :bad_request
    end
  end
end
