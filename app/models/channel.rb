##
# A "Channel" of Europeana content, e.g. Music or Fashion
#
# @todo Use ActiveModel
class Channel
  # @!attribute [r] id
  #   @return [String] the ID of the Channel
  #   @example 'music'
  attr_reader :id

  # @!attribute [rw] config
  #   @return [Hash] the configuration for the Channel
  attr_accessor :config

  def self.find(id)
    unless Rails.application.config.x.channels.key?(id)
      fail Channels::Errors::NoChannelConfiguration,
           "Channel \"#{id}\" is not configured"
    end
    channel = new(id)
    channel.config = Rails.application.config.x.channels[id]
    channel
  end

  # @param [String] id The Channel ID
  def initialize(id)
    unless id.is_a?(String)
      fail ArgumentError, "Channel ID must be a String, but is a #{id.class}"
    end
    @id = id
  end

  def method_missing(meth, *_args, &_block)
    config[meth] if config.key?(meth)
  end
end
