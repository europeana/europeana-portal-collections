##
# Configures Blacklight for Europeana Channels
#
module ChannelsBlacklightConfig
  extend ActiveSupport::Concern

  included do
    configure_blacklight do |config|
      # Default parameters to send to solr for all search-like requests.
      # See also SolrHelper#solr_search_params
      config.default_solr_params = {
        qt: 'search',
        rows: 24
      }

      # Custom response and document models for Europeana data modelling
      config.solr_response_model = Europeana::Response
      config.solr_document_model = Europeana::Document

      # items to show per page, each number in the array represents another
      # option to choose from.
      config.per_page = [12, 24, 48, 96]

      # solr field configuration for search results/index views
      config.index.title_field = 'title'
      config.index.display_type_field = 'type'
      config.index.thumbnail_field = 'edmPreview'

      # Facet fields in the order they should be displayed.
      config.add_facet_field 'UGC', label: 'UGC', limit: 7
      config.add_facet_field 'LANGUAGE', label: 'LANGUAGE', limit: 7
      config.add_facet_field 'TYPE', label: 'TYPE', limit: 7
      config.add_facet_field 'YEAR', label: 'YEAR', limit: 7
      config.add_facet_field 'PROVIDER', label: 'PROVIDER', limit: 7
      config.add_facet_field 'DATA_PROVIDER', label: 'DATA_PROVIDER', limit: 7
      config.add_facet_field 'COUNTRY', label: 'COUNTRY', limit: 7
      config.add_facet_field 'RIGHTS', label: 'RIGHTS', limit: 7

      # Send all facet field names to Solr.
      config.add_facet_fields_to_solr_request!

      # Fields to be displayed in the object view, in the order of display.
      config.add_show_field 'edmPreview', label: 'Preview'
      config.add_show_field 'dcType_def', label: 'Type'
      config.add_show_field 'dctermsExtent_def', label: 'Format'
      config.add_show_field 'dcSubject_def', label: 'Subject'
      config.add_show_field 'dcIdentifier_def', label: 'Identifier'
      config.add_show_field 'dctermsProvenance_def', label: 'Provenance'
      config.add_show_field 'edmDataProvider_def', label: 'Data provider'
      config.add_show_field 'edmProvider_def', label: 'Provider'
      config.add_show_field 'edmCountry_def', label: 'Providing country'

      # "fielded" search configuration.
      %w(all_fields title who what when where subject).each do |field_name|
        config.add_search_field(field_name) do |field|
          field.solr_local_parameters = {
            qf: field_name
          }
        end
      end
    end
  end
end
