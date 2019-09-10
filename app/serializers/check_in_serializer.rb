class CheckInSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :watered, :fertilized, :notes, :plant_id

  def created_at
    object.created_at.to_i
  end
end
