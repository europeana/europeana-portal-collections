# A "Channel" of Europeana content, e.g. Music or Fashion
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
    raise ArgumentError, "Channel ID must be a Symbol, but is a #{id.class.to_s}" unless id.is_a?(Symbol)
    @id = id
  end
  
  def self.find(id)
    raise Channels::Errors::NoChannelConfiguration, "Channel \"#{id.to_s}\" is not configured" unless Channels::Application.config.channels.has_key?(id)
    channel = self.new(id)
    channel.config = Channels::Application.config.channels[id]
    channel
  end
  
  def method_missing(meth, *args, &block)
    if config.has_key?(meth)
      config[meth]
    else
      super
    end
  end
end
