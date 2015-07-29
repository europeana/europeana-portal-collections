module Europeana
  module Channels
    extend ActiveSupport::Concern
    include ChannelsHelper

    ##
    # Adds channel filter params to the API query
    def search_builder(processor_chain = search_params_logic)
      super(processor_chain).with_overlay_params(current_channel.config[:params])
    end

    def has_search_parameters?
      super || params.key?(:q)
    end

    ##
    # Returns the current channel being viewed by the user
    #
    # @return [Channel]
    def current_channel
      return nil unless within_channel?
      Channel.find(params[:id])
    end

    ##
    # Returns the current channel the current search was performed in
    #
    # @return [Channel]
    def current_search_channel
      return nil unless current_search_session.query_params[:id]
      Channel.find(current_search_session.query_params[:id])
    end
  end
end
