class PlantSerializer < ActiveModel::Serializer
  attributes :id, :name, :last_watered_at, :next_check_date

  def last_watered_at
    object.last_watered_at.to_i
  end
end
