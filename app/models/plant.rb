class Plant < ApplicationRecord
  has_many :waterings

  def last_watering
    waterings.order(watered_at: :desc).take
  end

  def last_watering_date
    last_watering&.watered_at_date
  end
end
