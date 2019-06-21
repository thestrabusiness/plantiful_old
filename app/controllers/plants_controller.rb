class PlantsController < ApplicationController
  def index
    @plants = Plant.all
  end

  def new
  end

  def create
    Plant.create(plant_params)
    flash[:success] = 'plant created!'
    redirect_to plants_path
  end

  private

  def plant_params
    params.require(:plant).permit(:name, :botanical_name)
  end
end
