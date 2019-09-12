class PlantSerializer < ActiveModel::Serializer
  attributes :id, :name, :last_watered_at, :next_check_date, :check_ins, :avatar
  include Rails.application.routes.url_helpers

  has_many :check_ins do
    object.check_ins.limit(5)
  end

  def avatar
    return unless object.avatar.attached?

    rails_representation_url(object.avatar.variant(resize: '300x300').processed)
  end

  def last_watered_at
    object.last_watered_at.to_i
  end
end
