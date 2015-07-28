module Europeana
  module Channels
    extend ActiveSupport::Concern
    include ChannelsHelper

    included do
      self.search_params_logic = Europeana::Blacklight::SearchBuilder.default_processor_chain +
        [:add_channel_qf_to_api]
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

    ##
    # Looks up and returns any additional hidden query parameters used to
    # restrict results to the active channel.
    #
    # @return [String]
    def channel_filter_params
      channel = current_channel || current_search_channel
      channel.nil? ? nil : channel.params
    end
  end
end
