class Plant < ApplicationRecord
  FREQUENCY_UNITS = %w[day week].freeze

  belongs_to :garden
  belongs_to :added_by, class_name: 'User'
  has_many :users, through: :garden
  has_many :check_ins, dependent: :destroy
  has_one :last_check_in, class_name: 'CheckIn'
  has_one :last_check, -> { check_in }, class_name: 'CheckIn'
  has_one :last_fertilizing, -> { fertilized }, class_name: 'CheckIn'
  has_one :last_watering, -> { watered }, class_name: 'CheckIn'
  has_many :checks, -> { check_in }, class_name: 'CheckIn'
  has_many :fertilizings, -> { fertilized }, class_name: 'CheckIn'
  has_many :waterings, -> { watered }, class_name: 'CheckIn'
  has_many :photos, through: :check_ins

  has_one_base64_attached :avatar

  validates :added_by, :garden, :name, presence: true
  validates :check_frequency_scalar, presence: true, numericality: true
  validates :check_frequency_unit, presence: true, inclusion: FREQUENCY_UNITS

  def self.need_care
    joins(:check_ins)
      .where(
        'check_ins.created_at = (SELECT MAX(check_ins.created_at)
        FROM check_ins WHERE check_ins.plant_id = plants.id)'
      )
      .where(
        "check_ins.created_at + #{care_frequency_interval_sql} <= now()"
      ).uniq
  end

  def check_frequency
    check_frequency_scalar.public_send(check_frequency_unit)
  end

  def last_watered_at
    last_watering&.created_at
  end

  def last_watering_date
    last_watering&.created_at_date
  end

  def needs_care?
    next_check_time.to_date <= Time.current.to_date
  end

  def next_check_date
    l(next_check_time, format: :month_day_year)
  end

  def next_check_time
    time_from_check_in = recent_check_in.created_at + check_frequency
    [time_from_check_in, Time.current].max
  end

  private

  def self.care_frequency_interval_sql
    "(check_frequency_scalar || ' ' || check_frequency_unit::TEXT)::INTERVAL"
  end

  def recent_check_in
    last_check_in || NullCheckIn.new(self)
  end
end
