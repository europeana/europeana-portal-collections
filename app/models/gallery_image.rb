# frozen_string_literal: true
class GalleryImage < ActiveRecord::Base
  belongs_to :gallery, inverse_of: :images

  validates :gallery, presence: true
  validates :europeana_record_id,
            presence: true, format: { with: Europeana::Record::ID_PATTERN }

  ##
  # Gets the URL of the item on the portal that this gallery image represents
  def portal_url
    @portal_url ||= Europeana::Record.portal_url_from_id(europeana_record_id)
  end
end
