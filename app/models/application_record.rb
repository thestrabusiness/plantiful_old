class ApplicationRecord < ActiveRecord::Base
  include ActionView::Helpers::TranslationHelper
  include ActiveStorageSupport::SupportForBase64
  self.abstract_class = true
end
