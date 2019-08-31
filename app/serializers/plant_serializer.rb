class PlantSerializer < ActiveModel::Serializer
  attributes :id, :name, :last_watered_at, :next_check_date, :check_ins

  has_many :check_ins do
    object.check_ins.limit(5)
  end


  def last_watered_at
    object.last_watered_at.to_i
  end
end
