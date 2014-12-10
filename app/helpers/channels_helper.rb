module ChannelsHelper
  def available_channels
    Channels::Application.config.channels.keys
  end
end
