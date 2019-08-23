module Api
  class PlantCareEventsController < Api::BaseController
    def create
      plant = current_user.plants.find(params[:plant_id])
      if plant.plant_care_events.create(kind: params[:kind])
        render json: plant, status: :created
      else
        head :bad_request
      end
    end
  end
end
