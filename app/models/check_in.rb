class CheckIn < ApplicationRecord
  belongs_to :plant

  has_many_base64_attached :photos

  validates :plant, presence: true

  scope :check_in, -> { where(fertilized: false, watered: false) }
  scope :fertilized, -> { where(fertilized: true) }
  scope :watered, -> { where(watered: true) }

  default_scope -> { order(created_at: :desc) }

  def created_at_date
    l(created_at, format: :month_day_year)
  end

  def attach_photos(new_photos)
    return if new_photos.nil?

    new_photos.each do |photo|
      photos.attach(data: photo)
    end
  end
end
