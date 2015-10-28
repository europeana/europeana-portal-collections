module Europeana
  module Collections
    extend ActiveSupport::Concern
    include CollectionsHelper

    ##
    # Adds collection filter params to the API query
    def search_builder(processor_chain = search_params_logic)
      super(processor_chain).with_overlay_params(current_collection.api_params_hash)
    end

    def has_search_parameters?
      super || params.key?(:q)
    end

    ##
    # Returns the current collection being viewed by the user
    #
    # @return [Collection]
    def current_collection
      return nil unless within_collection?
      Collection.find_by_key!(params[:id])
    end

    ##
    # Returns the current collection the current search was performed in
    #
    # @return [Collection]
    def current_search_collection
      return nil unless current_search_session.query_params[:id]
      Collection.find_by_key!(current_search_session.query_params[:id])
    end
  end
end
