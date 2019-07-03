class PlantSerializer < ActiveModel::Serializer
  attributes :id, :name, :last_watering_date
end
