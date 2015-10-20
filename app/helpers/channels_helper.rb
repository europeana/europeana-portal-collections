##
# Channels helpers
module ChannelsHelper
  def available_channels
    Channel.all.map(&:key)
  end

  def within_channel?(localized_params = params)
    localized_params['controller'] == 'channels' &&
      localized_params['id'].present?
  end
end
