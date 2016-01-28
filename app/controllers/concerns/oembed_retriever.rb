require 'oembed'

module OembedRetriever
  extend ActiveSupport::Concern

  include ActiveSupport::Benchmarkable

  # @param doc {Europeana::Blacklight::Document} Document to scan for OEmbed URLs
  # @param conversions {Hash} Map of URL conversions, e.g. for SoundCloud URNs
  def oembed_html_for_urls(doc, conversions = {})
    uris = (doc.fetch('aggregations.edmIsShownBy', []) || []) + (doc.fetch('webResources.about', []) || [])
    urls = uris.map { |u| conversions.key?(u) ? conversions[u] : u }

    urls.uniq.each_with_object({}) do |url, map|
      unless OEmbed::Providers.find(url).nil?
        benchmark("[OEmbed] #{url}", level: :info) do
          map[url] = OEmbed::Providers.get(url).html
        end
      end
    end
  end
end
