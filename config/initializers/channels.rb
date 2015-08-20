Rails.application.configure do
  # Load Channels configuration files from config/channels/*.yml files
  config.channels = begin
    channel_yamls = Dir[Rails.root.join('config', 'channels', '*.yml')]
    channel_yamls.each_with_object(HashWithIndifferentAccess.new) do |yml, hash|
      channel = File.basename(yml, '.yml')
      hash[channel] = YAML::load_file(yml)
    end
  end
end
