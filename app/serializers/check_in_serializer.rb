class CheckInSerializer < BaseSerializer
  attributes :id, :created_at, :watered, :fertilized, :notes, :plant_id, :photo_urls

  def created_at
    object.created_at.to_i
  end

  def photo_urls
    object.photos.map do |photo|
      rails_representation_url(photo.variant(resize: '70x70').processed)
    end
  end
end
