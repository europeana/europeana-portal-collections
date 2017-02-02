# frozen_string_literal: true
json.description render_document_show_field_value(@document, 'proxies.dcDescription')
json.creation_date render_document_show_field_value(@document, 'proxies.dcDate')
json.data_provider render_document_show_field_value(@document, 'aggregations.edmDataProvider')
json.provider render_document_show_field_value(@document, 'aggregations.edmProvider')
json.rights do |rights|
  rights.license_CC0
  rights.license_url render_document_show_field_value(@document, 'aggregations.edmRights')
end
json.url_collection search_url(q: %(edm_datasetName:"#{render_document_show_field_value(@document, 'edmDatasetName')}"))
