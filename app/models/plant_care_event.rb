class PlantCareEvent < ApplicationRecord
  belongs_to :plant

  KINDS = %w[watering check].freeze

  validates :kind, inclusion: KINDS
  validates :plant, presence: true

  default_scope -> { order(happened_at: :desc) }

  scope :watering, -> { where kind: 'watering' }
  scope :check, -> { where kind: 'check' }

  def happened_at_date
    l(happened_at, format: :month_day_year)
  end
end
