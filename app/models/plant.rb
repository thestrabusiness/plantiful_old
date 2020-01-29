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

  time_for_a_boolean :deleted

  validates :added_by, :garden, :name, presence: true
  validates :check_frequency_scalar, presence: true, numericality: true
  validates :check_frequency_unit, presence: true, inclusion: FREQUENCY_UNITS

  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  def self.need_care
    NeedsCheckIn.plants(self)
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

  def attach_avatar(base64_data)
    avatar.attach(data: base64_data)
  end

  private

  def recent_check_in
    last_check_in || NullCheckIn.new(self)
  end
end
