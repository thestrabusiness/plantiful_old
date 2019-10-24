class GardenSerializer < BaseSerializer
  attributes :id, :name, :owner_id, :plants

  has_many :plants
end

