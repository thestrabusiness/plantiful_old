class PlantsController < ApplicationController
  def index
    @plants = Plant.includes(:last_watering)
  end

  def new; end

  def create
    Plant.create(plant_params)
    flash[:success] = 'plant created!'
    redirect_to plants_path
  end

  def show
    @plant = Plant.includes(:waterings).find(params[:id])
  end

  private

  def plant_params
    params.require(:plant).permit(:name, :botanical_name)
  end
end
