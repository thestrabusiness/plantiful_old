class User < ApplicationRecord
  include Clearance::User

  belongs_to :garden
  has_many :plants, through: :garden
  has_many :waterings, through: :plants

  validates :first_name, :last_name, presence: true
  validates :garden, presence: true

  def full_name
    [first_name, last_name].join(' ')
  end

  def default_garden_name
    "#{first_name}'s Garden"
  end
end
