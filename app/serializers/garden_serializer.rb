class GardenSerializer < BaseSerializer
  attributes :id, :name, :owner_id

  has_many :plants do
    object.plants.active
  end
end
