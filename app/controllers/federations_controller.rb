# frozen_string_literal: true
##
# Provides Federated content via JSON, to be displayed within a content Collection
class FederationsController < ApplicationController
  # The federated action which is used to retrieve federated results via the foederati gem.
  def show
    @collection = find_collection
    provider = params[:id]
    federation_config = @collection.federation_configs.where(provider: provider).first
    @query = "#{params[:query]} #{federation_config.context_query}"
    if @collection.federation_configs && federation_config
      foederati_provider = Foederati::Providers.get(provider.to_sym)
      @federated_results = Foederati.search(provider.to_sym, query: @query)[provider.to_sym]
      @federated_results[:more_results_label] = t('global.actions.view-more-at') + foederati_provider.display_name
      @federated_results[:more_results_url] = format(foederati_provider.urls.site, query: @query)
      @federated_results[:tab_subtitle] = [@federated_results[:total], t('site.results.results')].join(' ')

      @federated_results[:search_results] = @federated_results.delete(:results)
      @federated_results[:search_results].each do |result|
        result[:img] = { src: result.delete(:thumbnail) } if result[:thumbnail]
        result[:object_url] = result.delete(:url)
      end
    end
    render json: @federated_results
  rescue
    render json: { tab_subtitle: t('global.error.unavailable'), search_results: [] }
  end

  def find_collection
    Collection.find_by_key!(params[:collection]).tap do |collection|
      authorize! :show, collection
    end
  end
end
