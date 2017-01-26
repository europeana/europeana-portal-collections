# frozen_string_literal: true
##
# Represents a Europeana record as harvested from the Record API
#
# @see http://labs.europeana.eu/api/record
class Europeana::Record < ActiveRecord::Base
  self.table_name = 'europeana_records'

  has_many :gallery_images, dependent: :destroy, inverse_of: :europeana_record

  EUROPEANA_ID_PATTERN = %r{\A/[^/]+/[^/]+\z}
#   EUROPEANA_ID_FROM_URL_PATTERN = /\Ahttps?:\/\/www\.europeana\.eu(?=\.html)|\/[^\/]+\/[^\/]+(?!\.html))\z/

  validates :europeana_id, presence: true, uniqueness: true,
    format: { with: EUROPEANA_ID_PATTERN }

  after_create :enqueue_harvest_job

  ##
  # Extracts a Europeana ID from a variety of known URL formats
  #
  # @param url [String] URL to extract from
  # @return [String] Europeana ID
  def self.europeana_id_from_url(url)
    uri = URI.parse(url)
    return nil unless %w(http https).include?(uri.scheme)
    return nil unless uri.host == 'www.europeana.eu'
    extension = /\.[a-z]+\z/i.match(uri.path)
    return nil unless extension.nil? || extension[0] == '.html'
#     path = File.basename(uri.path, '.html')
    match = /\A\/portal(\/[a-z]{2})?\/record(\/[^\/]+\/[^\/]+)#{extension}\z/.match(uri.path)
    match.nil? ? nil : match[2]
  end

  ##
  # Returns the language-agnostic portal URL for this Europeana record
  #
  # @return [String]
  def url
    "http://www.europeana.eu/portal/record#{europeana_id}.html"
  end

  protected

  def enqueue_harvest_job
    HarvestEuropeanaRecordJob.perform_later(id)
  end
end
