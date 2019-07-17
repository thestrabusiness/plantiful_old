class Plant < ApplicationRecord
  belongs_to :user
  has_many :waterings, -> { order(watered_at: :desc) }
  has_one :last_watering, -> { order(watered_at: :desc) }, class_name: 'Watering'

  validates :user, presence: true

  def last_watering_date
    last_watering&.watered_at_date
  end
end
