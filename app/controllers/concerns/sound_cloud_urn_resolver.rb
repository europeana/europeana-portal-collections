require 'soundcloud'

module SoundCloudUrnResolver
  extend ActiveSupport::Concern

  def soundcloud_urns_to_urls(doc)
    return {} unless soundcloud_configured?

    doc['aggregations'].each_with_object({}) do |agg, map|
      next unless agg['edmIsShownBy'].present?
      urn_match = agg['edmIsShownBy'].match(/\Aurn:soundcloud:(.*)\z/)
      unless urn_match.nil?
        begin
          map[agg['edmIsShownBy']] = soundcloud_url(urn_match[1])
        rescue SoundCloud::ResponseError
          # do nothing, i.e. no mapping
        end
      end
    end
  end

  ##
  # Queries SoundCloud API for track URL from its ID
  def soundcloud_url(id)
    soundcloud_client.get("/tracks/#{id.strip}").permalink_url
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
