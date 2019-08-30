class Plant < ApplicationRecord
  FREQUENCY_UNITS = %w[day week].freeze

  belongs_to :user
  has_many :plant_care_events
  has_one :last_care_event, class_name: 'PlantCareEvent'
  has_one :last_watering, -> { watering }, class_name: 'PlantCareEvent'
  has_one :last_check, -> { check }, class_name: 'PlantCareEvent'
  has_many :waterings, -> { watering }, class_name: 'PlantCareEvent'
  has_many :checks, -> { check }, class_name: 'PlantCareEvent'

  validates :user, :name, presence: true
  validates :check_frequency_scalar, presence: true, numericality: true
  validates :check_frequency_unit, presence: true, inclusion: FREQUENCY_UNITS

  def self.need_care
    joins(:plant_care_events)
      .where(
        "plant_care_events.happened_at + #{care_frequency_interval_sql}
        <= now()"
      )
  end

  def last_watered_at
    last_watering&.happened_at
  end

  def last_watering_date
    last_watering&.happened_at_date
  end

  def next_check_date
    l(next_check_time, format: :month_day_year)
  end

  def check_frequency
    check_frequency_scalar.public_send(check_frequency_unit)
  end

  def needs_care?
    next_check_time <= Time.current
  end

  private

  def self.care_frequency_interval_sql
    "(check_frequency_scalar || ' ' || check_frequency_unit::TEXT)::INTERVAL"
  end

  def recent_care_event
    last_care_event || NullCareEvent.new(self)
  end

  def next_check_time
    time_from_care_event = recent_care_event.happened_at + check_frequency
    [time_from_care_event, Time.current].max
  end
end
