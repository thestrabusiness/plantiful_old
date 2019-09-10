class CheckIn < ApplicationRecord
  belongs_to :plant

  validates :plant, presence: true

  scope :check_in, -> { where(fertilized: false, watered: false) }
  scope :fertilized, -> { where(fertilized: true) }
  scope :watered, -> { where(watered: true) }

  default_scope -> { order(created_at: :desc) }

  def created_at_date
    l(created_at, format: :month_day_year)
  end
end
