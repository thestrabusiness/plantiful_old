class Garden < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :plants
  belongs_to :owner, class_name: 'User'

  after_create :add_owner_to_users

  validates :name, :owner, presence: true

  private

  def add_owner_to_users
    users << owner
  end
end
