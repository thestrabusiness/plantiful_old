class User < ApplicationRecord
  include Clearance::User

  has_many :plants
  has_many :waterings, through: :plants
end