module Api
  class PlantsController < Api::BaseController
    def index
      garden = Garden.find(params[:garden_id])
      plants = garden.plants

      render json: plants
        .active
        .with_attached_avatar
        .includes(:last_watering, :last_check_in)
        .sort_by(&:next_check_time)
    end

    def create
      garden = Garden.find(params[:garden_id])

      create_params = plant_params.except(:avatar).merge(added_by: current_user)
      plant = garden.plants.create(create_params)

      if plant_params[:avatar]
        plant.avatar.attach(data: plant_params[:avatar])
      end

      if plant.errors.empty?
        render json: plant, status: :created
      else
        render json: plant.errors, status: :unprocessable_entity
      end
    end

    def show
      plant = current_user
              .active_plants
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

    def destroy
      plant = current_user.plants.find(params[:id])
      plant.update(deleted: true)
      head :ok
    end

    def update
      plant = current_user.plants.find(params[:id])

      if plant.update(plant_params)
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
