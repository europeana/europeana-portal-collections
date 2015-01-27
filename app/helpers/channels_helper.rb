module ChannelsHelper
  def available_channels
    Channels::Application.config.channels.keys
  end
  
  def within_channel?(localized_params = params)
    localized_params['controller'] == 'channels' and localized_params['action'] == 'show' and localized_params['id'].present?
  end
end
