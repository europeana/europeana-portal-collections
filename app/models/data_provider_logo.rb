class DataProviderLogo < ActiveRecord::Base
  belongs_to :data_provider, inverse_of: :logo

  has_attached_file :image, styles: { medium: "300>" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
end
