class CheckInSerializer < ActiveModel::Serializer
  attributes :id, :watered, :fertilized, :notes
  belongs_to :plant
end
