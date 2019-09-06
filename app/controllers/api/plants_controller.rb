module Api
  class PlantsController < Api::BaseController
    def index
      render json: current_user
        .plants
        .includes(:last_watering, :last_check_in)
    end

    def create
      plant = current_user.plants.create(plant_params)
      if plant.errors.empty?
        render json: plant, status: :created
      else
        render json: plant.errors, status: :unprocessable_entity
      end
    end

    def show
      plant = current_user.plants.find(params[:id])

      render json: plant, status: :ok
    end

    def photo
      plant = current_user.plants.find(params[:id])
      plant.attach(params[:photo])
      if plant.valid?
        render json: plant, status: :updated
      else
        render json: plant.errors, status: :unprocessable_entity
      end
    end

    private

    def plant_params
      params.require(:plant).permit(
        :name,
        :check_frequency_unit,
        :check_frequency_scalar
      )
    end
  end
end
