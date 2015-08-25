Rails.application.configure do
  # Paperclip file storage config
  config.paperclip_defaults = {
    path: ':class/:id_partition/:attachment/:fingerprint.:style.:extension',
    styles: { small: '200>', medium: '400>', large: '600>' } # max-width
  }
  config.paperclip_defaults.merge! begin
    paperclip_config = Rails.application.config_for(:paperclip)
    fail RuntimeError unless paperclip_config.present?
    paperclip_config.deep_symbolize_keys
  rescue RuntimeError
    {}
  end

  # Create public Fog directory/bucket if required
  paperclip_config = config.paperclip_defaults
  fog_directory = paperclip_config[:fog_directory]

  if paperclip_config[:storage] == :fog && fog_directory.present?
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
