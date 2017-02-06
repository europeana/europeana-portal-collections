# frozen_string_literal: true
presenter = Document::RecordPresenter.new(@document, controller)

json.description presenter.field_value('proxies.dcDescription')
json.creation_date presenter.field_value('proxies.dcDate')
json.data_provider presenter.field_value('aggregations.edmDataProvider')
json.provider presenter.field_value('aggregations.edmProvider')
json.rights presenter.simple_rights_label_data
json.url_collection search_url(q: %(edm_datasetName:"#{presenter.field_value('edmDatasetName')}"))
