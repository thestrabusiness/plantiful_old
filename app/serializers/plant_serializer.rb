class PlantSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :avatar, :check_ins, :id, :last_watered_at, :name,
             :next_check_date, :overdue_for_check_in

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

  def overdue_for_check_in
    object.needs_care?
  end
end
