# frozen_string_literal: true
class GalleryImage < ActiveRecord::Base
  belongs_to :gallery, inverse_of: :images
  belongs_to :europeana_record, class_name: 'Europeana::Record'

  validates :gallery, presence: true
  validates :europeana_record, presence: true

  delegate :url, :metadata, to: :europeana_record

  ##
  # Sets the associated `Europeana::Record` by finding or building one from
  # the passed URL
  #
  # @param url [String] URL of Europeana Record
  def url=(url)
    europeana_id = Europeana::Record.europeana_id_from_url(url)
    return if europeana_id.nil?
    self.europeana_record = Europeana::Record.find_or_initialize_by(europeana_id: europeana_id)
  end
end
