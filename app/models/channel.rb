##
# A "Channel" of Europeana content, e.g. Music or Fashion
#
# @todo Use ActiveModel
class Channel
  # @!attribute [r] id
  #   @return [Symbol] the ID of the Channel
  #   @example :music
  attr_reader :id

  # @!attribute [rw] config
  #   @return [Hash] the configuration for the Channel
  attr_accessor :config

  # @param [Symbol] id The Channel ID
  def initialize(id)
    unless id.is_a?(Symbol)
      fail ArgumentError, "Channel ID must be a Symbol, but is a #{id.class}"
    end
    @id = id
  end

  def self.find(id)
    unless Europeana::Portal::Application.config.channels.key?(id)
      fail Channels::Errors::NoChannelConfiguration,
           "Channel \"#{id}\" is not configured"
    end
    channel = new(id)
    channel.config = Europeana::Portal::Application.config.channels[id]
    channel
  end

  def method_missing(meth, *_args, &_block)
    config[meth] if config.key?(meth)
  end
end
