module Api
  class PlantsController < Api::BaseController
    def index
      render json: current_user
        .plants
        .with_attached_avatar
        .includes(:last_watering, :last_check_in)
        .sort_by(&:next_check_time)
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
      plant = current_user
        .plants
        .with_attached_avatar
        .includes(check_ins: :photos_attachments)
        .find(params[:id])
      render json: plant, status: :ok
    end

    def avatar
      plant = current_user.plants.find(params[:id])
      plant.avatar.attach(data: plant_params[:avatar])

      if plant.valid?
        render json: plant, status: :ok
      else
        render json: plant.errors, status: :unprocessable_entity
      end
    end

    private

    def plant_params
      params.require(:plant).permit(
        :name,
        :check_frequency_unit,
        :check_frequency_scalar,
        :avatar
      )
    end
  end
end
