module Api
  class CheckInsController < Api::BaseController
    def create
      plant = current_user.plants.find(params[:plant_id])
      check_in = plant.check_ins.create(check_in_attrs)
      check_in.attach_photos(photos)
      if check_in.valid?
        render json: check_in, status: :created
      else
        head :bad_request
      end
    end

    private

    def check_in_params
      params
        .require(:check_in)
        .permit(:notes, :watered, :fertilized, photos: [])
    end

    def check_in_attrs
      check_in_params.except(:photos)
    end

    def photos
      check_in_params[:photos]
    end
  end
end
