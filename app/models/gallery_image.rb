# frozen_string_literal: true

class GalleryImage < ActiveRecord::Base
  include Annotation
  include EuropeanaRecordAPI
  include HTTPResponse

  belongs_to :gallery, inverse_of: :images, touch: true

  validates :gallery, presence: true
  validates :europeana_record_id,
            presence: true, format: { with: Europeana::Record::ID_PATTERN }
  validates :url, presence: true

  def portal_url
    url.nil? ? europeana_record.portal_url : europeana_record.portal_url + '?view=' + CGI.escape(url)
  end
end
