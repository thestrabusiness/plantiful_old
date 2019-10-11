module Api
  class GardensController < Api::BaseController
    def create
      garden = current_user.owned_gardens.create(garden_params)

      if garden.valid?
        render json: garden, status: :ok
      else
        render json: garden.errors, status: :unprocessable_entity
      end
    end

    def update
      garden = Garden.find(params[:id])

      if garden.update(garden_params)
        render json: garden, status: :ok
      else
        render json: garden.errors, status: :unprocessable_entity
      end
    end

    def destroy
      garden = Garden.find(params[:id])

      if garden.destroy
        head :ok
      else
        head :bad_request
      end
    end

    private

    def garden_params
      params.require(:garden).permit(:name)
    end
  end
end
