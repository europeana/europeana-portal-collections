# frozen_string_literal: true
##
# Provides Blacklight search and browse, within a content Collection
class FederationsController < ApplicationController
  # The federated action which is used to retrieve federated results via the foederati gem.
  def show
    @collection = find_collection
    provider = params[:id]
    @query = params[:query]
    if @collection.settings_federated_providers && @collection.settings_federated_providers.detect(provider.to_sym)
      foederati_provider = Foederati::Providers.get(provider.to_sym)
      @federated_results = Foederati.search(provider.to_sym, query: @query)[provider.to_sym]
      @federated_results[:more_results_label] = "View more at #{foederati_provider.display_name}"
      @federated_results[:more_results_url] = format(foederati_provider.urls.site, query: @query)
      @federated_results[:tab_subtitle] = "#{@federated_results[:total]} Results"

      @federated_results[:search_results] = @federated_results.delete(:results)
      @federated_results[:search_results].each do |result|
        result[:img] = { src: result.delete(:thumbnail) } if result[:thumbnail]
        result[:object_url] = result.delete(:url)
      end
    end
    render json: @federated_results
  end

  def find_collection
    Collection.find_by_key!(params[:collection]).tap do |collection|
      authorize! :show, collection
    end
  end
end