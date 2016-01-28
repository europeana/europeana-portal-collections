require 'soundcloud'

module SoundCloudUrnResolver
  extend ActiveSupport::Concern

  include ActiveSupport::Benchmarkable

  def soundcloud_urns_to_urls(doc)
    return {} unless soundcloud_configured?

    doc.fetch('aggregations.edmIsShownBy', []).each_with_object({}) do |edm_is_shown_by, map|
      urn_match = edm_is_shown_by.match(/\Aurn:soundcloud:(.*)\z/)
      unless urn_match.nil?
        begin
          map[edm_is_shown_by] = soundcloud_url(urn_match[1])
        rescue SoundCloud::ResponseError
          # do nothing, i.e. no mapping
        end
      end
    end
  end

  ##
  # Queries SoundCloud API for track URL from its ID
  def soundcloud_url(id)
    benchmark("[SoundCloud API] #{id}", level: :info) do
      soundcloud_client.get("/tracks/#{id.strip}").permalink_url
    end
  end

  private

  def soundcloud_configured?
    ENV.key?('SOUNDCLOUD_CLIENT_ID')
  end

  def soundcloud_client
    @soundcloud_client ||= begin
      SoundCloud.new(client_id: ENV['SOUNDCLOUD_CLIENT_ID'])
    end
  end
end
