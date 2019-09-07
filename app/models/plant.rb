class Plant < ApplicationRecord
  FREQUENCY_UNITS = %w[day week].freeze

  belongs_to :user
  has_many :check_ins
  has_one :last_check_in, class_name: 'CheckIn'
  has_one :last_check, -> { check_in }, class_name: 'CheckIn'
  has_one :last_fertilizing, -> { fertilized }, class_name: 'CheckIn'
  has_one :last_watering, -> { watered }, class_name: 'CheckIn'
  has_many :checks, -> { check_in }, class_name: 'CheckIn'
  has_many :fertilizings, -> { fertilized }, class_name: 'CheckIn'
  has_many :waterings, -> { watered }, class_name: 'CheckIn'

  has_one_base64_attached :photo

  validates :user, :name, presence: true
  validates :check_frequency_scalar, presence: true, numericality: true
  validates :check_frequency_unit, presence: true, inclusion: FREQUENCY_UNITS

  def self.need_care
    joins(:check_ins)
      .where(
        "check_ins.created_at + #{care_frequency_interval_sql}
        <= now()"
      )
  end

  def last_watered_at
    last_watering&.created_at
  end

  def last_watering_date
    last_watering&.created_at_date
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

  def recent_check_in
    last_check_in || NullCheckIn.new(self)
  end

  def next_check_time
    time_from_check_in = recent_check_in.created_at + check_frequency
    [time_from_check_in, Time.current].max
  end
end
