class DataProviderLogo < ActiveRecord::Base
  belongs_to :data_provider

  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
end
