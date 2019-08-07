class PlantSerializer < ActiveModel::Serializer
  attributes :id, :name, :last_watering_date, :next_check_date
end
