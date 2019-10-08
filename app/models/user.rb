class User < ApplicationRecord
  include Clearance::User

  has_and_belongs_to_many :gardens
  has_many :plants, through: :gardens
  has_many :waterings, through: :plants
  has_many :owned_gardens, foreign_key: :owner_id, class_name: 'Garden'

  validates :first_name, :last_name, presence: true

  def full_name
    [first_name, last_name].join(' ')
  end

  def default_garden_name
    "#{first_name}'s Garden"
  end
end
