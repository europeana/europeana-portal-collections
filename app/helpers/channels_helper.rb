##
# Channels helpers
module ChannelsHelper
  def available_channels
    Channels::Application.config.channels.keys
  end

  def within_channel?(localized_params = params)
    localized_params['controller'] == 'channels' &&
      localized_params['id'].present?
  end
end
