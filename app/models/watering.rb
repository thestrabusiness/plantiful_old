class Watering < ApplicationRecord
  belongs_to :plant

  def watered_at_date
    watered_at.strftime("%m/%d/%Y")
  end
end
