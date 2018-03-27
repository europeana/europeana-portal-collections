# frozen_string_literal: true

class DataProviderLogo < ActiveRecord::Base
  MIN_WIDTH = 0

  belongs_to :data_provider, inverse_of: :logo

  has_attached_file :image,
                    styles: { medium: "#{MIN_WIDTH}>" },
                    path: ':path_prefix/:class/:data_provider_org_id.:style.:extension',
                    url: ':url_prefix/:class/:data_provider_org_id.:style.:extension'

  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  attr_accessor :delete_image
  before_validation { image.clear if delete_image == '1' }

  validate :validate_image_width, if: :image?

  def validate_image_width
    dimensions = Paperclip::Geometry.from_file(image.queued_for_write[:original].path)
    errors[:image] << "Width must at least #{MIN_WIDTH}px" if dimensions.width < MIN_WIDTH
  end
end
