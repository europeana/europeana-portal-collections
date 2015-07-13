# Create public Fog directory/bucket if required
paperclip_config = Rails.application.config.paperclip_defaults
if paperclip_config[:storage] == :fog
  fog_directory = paperclip_config[:fog_directory]
  unless fog_directory.blank?
    connection = Fog::Storage.new(paperclip_config[:fog_credentials])
    directory = connection.directories.get(fog_directory)
    if directory.nil?
      directory = connection.directories.create(key: fog_directory)
      directory.public = true if directory.respond_to?(:public=)
      directory.save
    elsif directory.respond_to?(:public?) && !directory.public?
      fail "Fog storage directory not public: #{fog_directory}"
    end
  end
end
