##
# Channels helpers
module ChannelsHelper
  def available_channels
    Rails.application.config.x.channels.keys.sort
  end

  def within_channel?(localized_params = params)
    localized_params['controller'] == 'channels' &&
      localized_params['id'].present?
  end
end
