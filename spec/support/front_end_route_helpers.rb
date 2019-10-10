module FrontEndRouteHelpers
  def garden_path(garden, user = nil)
    path_builder("gardens/#{garden.id}", user)
  end

  def plant_path(plant, user = nil)
    path_builder("plants/#{plant.id}", user)
  end

  private

  def path_builder(path_name, user)
    "/#{path_name}?as=#{user&.id}"
  end
end
