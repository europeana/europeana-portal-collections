# frozen_string_literal: true

if @federated_results.present?
  json.total @federated_results[:total]
  json.more_results_label t('global.actions.view-more-at') + @foederati_provider.name
  json.more_results_url format(@foederati_provider.urls.site, query: @query)
  json.tab_subtitle [number_with_delimiter(@federated_results[:total]), t('site.results.results')].join(' ')
  json.search_results @federated_results[:results] do |result|
    json.title result[:title]
    json.img { json.src result[:thumbnail] } if result[:thumbnail]
    json.object_url result[:url]
  end
else
  json.tab_subtitle t('global.error.unavailable')
  json.search_results []
end
