module Europeana
  ##
  # Configures Blacklight for Europeana Portal & Channels
  module BlacklightConfig
    extend ActiveSupport::Concern

    included do
      def self.channels_query_facet
        channels = Europeana::Portal::Application.config.channels.dup
        channels.reject! { |_k, channel| channel[:query].blank? }
        channels.each_with_object({}) do |(k, v), hash|
          hash[k] = { label: k, fq: v[:query] }
        end
      end

      configure_blacklight do |config|
        # Default parameters to send to solr for all search-like requests.
        # See also SolrHelper#solr_search_params
        config.default_solr_params = {
          rows: 12
        }

        # Response models
        config.repository_class = Europeana::Blacklight::ApiRepository
        config.search_builder_class = Europeana::Blacklight::SearchBuilder
        config.response_model = Europeana::Blacklight::Response
        config.document_model = Europeana::Blacklight::Document
        config.document_presenter_class = Europeana::Blacklight::DocumentPresenter

        # items to show per page, each number in the array represents another
        # option to choose from.
        config.per_page = [12, 24, 48, 96]

        # solr field configuration for search results/index views
        config.index.title_field = 'title'
        config.index.display_type_field = 'type'
        config.index.thumbnail_field = 'edmPreview'

        # Max number of rows to retrieve for each facet
        config.default_facet_limit = 7

        # Facet fields in the order they should be displayed.
        config.add_facet_field 'CHANNEL', query: channels_query_facet
        config.add_facet_field 'TYPE', limit: true
        config.add_facet_field 'YEAR', limit: 30, range: true
        config.add_facet_field 'REUSABILITY', limit: true
        config.add_facet_field 'COUNTRY', limit: true
        config.add_facet_field 'LANGUAGE', limit: true
        config.add_facet_field 'PROVIDER', limit: true
        config.add_facet_field 'DATA_PROVIDER', limit: true

        # Send all facet field names to Solr.
        config.add_facet_fields_to_solr_request!

        # Fields to be displayed in the object view, in the order of display.
        config.add_show_field 'europeanaAggregation.edmPreview', label: 'Preview'
        config.add_show_field 'proxies.dcType', label: 'Type'
        config.add_show_field 'proxies.dctermsExtent', label: 'Format'
        config.add_show_field 'proxies.dcSubject', label: 'Subject'
        config.add_show_field 'proxies.dcIdentifier', label: 'Identifier'
        config.add_show_field 'proxies.dctermsProvenance', label: 'Provenance'
        config.add_show_field 'aggregations.edmDataProvider', label: 'Data provider'
        config.add_show_field 'aggregations.edmProvider', label: 'Provider'
        config.add_show_field 'europeanaAggregation.edmCountry', label: 'Providing country'

        # "fielded" search configuration.
        config.add_search_field('', :label => 'All Fields')
        %w(title who what when where subject).each do |field_name|
          config.add_search_field(field_name)
        end

        # Prevent BL's "did you mean" spellcheck feature kicking in
        config.spell_max = -1
      end
    end
  end
end
