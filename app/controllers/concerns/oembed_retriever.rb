# frozen_string_literal: true

require 'oembed'

module OembedRetriever
  extend ActiveSupport::Concern

  include ActiveSupport::Benchmarkable

  # @param doc {Europeana::Blacklight::Document} Document to scan for OEmbed URLs
  # @param conversions {Hash} Map of URL conversions, e.g. for SoundCloud URNs
  def oembed_for_urls(doc, conversions = {})
    uris = (doc.fetch('aggregations.edmIsShownBy', []) || []) + (doc.fetch('aggregations.webResources.about', []) || [])
    urls = uris.map { |u| conversions.key?(u) ? conversions[u] : u }

    urls.uniq.each_with_object({}) do |url, map|
      provider = OEmbed::Providers.find(url)
      next if provider.nil?
      benchmark("[OEmbed] #{url}", level: :info) do
        map[url] = {
          html: provider.get(url).html,
          link: provider.build(url)
        }
      rescue OEmbed::Error
        # no oEmbed HTML available (for a number of possible reasons)
      end
    end
  end
end
