# frozen_string_literal: true

##
# Provides Federated content via JSON, to be displayed within a content Collection
class FederationsController < ApplicationController
  # The federated action which is used to retrieve federated results via the foederati gem.
  def show
    collection = find_collection
    provider = params[:id]
    federation_config = collection.federation_configs.where(provider: provider).first

    unless federation_config.nil?
      @query = [params[:query], federation_config.context_query].reject(&:blank?).join(' AND ')
      @foederati_provider = Foederati::Providers.get(provider.to_sym)
      @federated_results = Foederati.search(provider.to_sym, query: @query)[provider.to_sym]
    end
  end

  protected

  def find_collection
    Collection.find_by_key!(params[:collection]).tap do |collection|
      authorize! :show, collection
    end
  end
end
