class WateringsController < ApplicationController
  def create

    plant = Plant.find(params[:plant_id])
    plant.waterings.create
    flash[:success] = 'Plant watered!'
    redirect_to plants_path
  end
end
