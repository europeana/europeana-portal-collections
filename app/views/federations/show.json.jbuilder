
@federated_results[:more_results_label] = t('global.actions.view-more-at') + @foederati_provider.display_name
@federated_results[:more_results_url] = format(@foederati_provider.urls.site, query: @query)
@federated_results[:tab_subtitle] = [@federated_results[:total], t('site.results.results')].join(' ')

@federated_results[:search_results] = @federated_results.delete(:results)
@federated_results[:search_results].each do |result|
  result[:img] = { src: result.delete(:thumbnail) } if result[:thumbnail]
  result[:object_url] = result.delete(:url)
end

json.( @federated_results, :total, :more_results_label, :more_results_url, :tab_subtitle, :search_results)