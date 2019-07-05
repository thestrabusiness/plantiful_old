class Api::WateringsController < ApplicationController
  def create
    @plant = Plant.find(params[:plant_id])
    if @plant.waterings.create
      render json: @plant, status: :ok
    else
      head :bad_request
    end
  end
end

