require 'oembed'

module OembedRetriever
  extend ActiveSupport::Concern

  def oembed_html_for_uris(doc, conversions = {})
    uris = (doc.fetch('aggregations.edmIsShownBy', []) || []) + (doc.fetch('webResources.about', []) || [])
    uris.map! { |u| conversions.key?(u) ? conversions[u] : u }

    uris.uniq.each_with_object({}) do |uri, map|
      unless OEmbed::Providers.find(uri).nil?
        map[uri] = OEmbed::Providers.get(uri).html
      end
    end
  end
end
