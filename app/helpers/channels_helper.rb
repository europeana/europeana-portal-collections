##
# Channels helpers
module ChannelsHelper
  def available_channels
    Europeana::Portal::Application.config.channels.keys.sort
  end

  def within_channel?(localized_params = params)
    localized_params['controller'] == 'channels' &&
      localized_params['id'].present?
  end
end
