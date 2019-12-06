class User < ApplicationRecord
  include Clearance::User

  has_and_belongs_to_many :gardens
  has_many :plants, through: :gardens
  has_many :active_plants, -> { active }, through: :gardens, source: :plants
  has_many :waterings, through: :plants
  has_many :owned_gardens, foreign_key: :owner_id, class_name: 'Garden'
  has_many :check_ins, foreign_key: :performed_by_id

  validates :first_name, :last_name, :mobile_api_token, presence: true

  # This is necessary because it appears that the default function values do not
  # get loaded on create. Without this, the mobile_api_token column is nil.
  #
  # See this issue: https://github.com/rails/rails/issues/34237
  after_initialize :generate_api_token, if: :new_record?

  def self.with_plants_that_need_care
    NeedsCheckIn.users(self)
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def default_garden_name
    "#{first_name}'s Garden"
  end

  def reset_mobile_api_token!
    update(mobile_api_token: SecureRandom.uuid)
  end

  private

  def generate_api_token
    self.mobile_api_token = SecureRandom.uuid
  end
end
