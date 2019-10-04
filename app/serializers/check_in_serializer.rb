class CheckInSerializer < BaseSerializer
  attributes :created_at, :fertilized, :id, :notes, :photo_urls, :plant_id,
             :watered

  def created_at
    object.created_at.to_i
  end

  def photo_urls
    object.photos.map do |photo|
      {
        preview: rails_representation_url(
          photo.variant(resize: '70x70').processed
        ),
        original: rails_blob_path(photo, disposition: 'inline')
      }
    end
  end
end
