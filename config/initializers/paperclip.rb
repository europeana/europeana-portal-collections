# Relative URL root interpolation used in filesystem URL paths
# @see /deploy/development/config/paperclip.yml
Paperclip.interpolates :rails_relative_url_root do |_attachment, _style|
  Rails.application.config.relative_url_root
end

# Basic Paperclip file storage settings
Paperclip::Attachment.default_options.merge!(
  path: ':class/:id_partition/:attachment/:fingerprint.:style.:extension',
  styles: { small: '200>', medium: '400>', large: '600>' } # max-width
)

# Load settings from paperclip.yml config file if present
Paperclip::Attachment.default_options.merge! begin
  paperclip_config = Rails.application.config_for(:paperclip)
  fail RuntimeError unless paperclip_config.present?
  paperclip_config.deep_symbolize_keys
rescue RuntimeError
  {}
end

paperclip_config = Paperclip::Attachment.default_options

# Create public Fog directory/bucket if required
# @todo Move to Rake task, to be run as part of app setup
# fog_directory = paperclip_config[:fog_directory]
# if paperclip_config[:storage] == :fog && fog_directory.present?
#   connection = Fog::Storage.new(paperclip_config[:fog_credentials])
#   directory = connection.directories.get(fog_directory)
#   if directory.nil?
#     directory = connection.directories.create(key: fog_directory)
#     directory.public = true if directory.respond_to?(:public=)
#     directory.save
#   elsif directory.respond_to?(:public?) && !directory.public?
#     fail "Fog storage directory not public: #{fog_directory}"
#   end
# end

# Swift URL retrieval is veeeery slow; cache the URLs
if paperclip_config[:storage] == :fog && paperclip_config[:fog_credentials][:provider] == 'OpenStack'
  require 'paperclip/attachment'

  module Paperclip
    class Attachment
      alias_method :gem_url, :url

      def url(style_name = default_style, options = {})
        cache_key = "#{instance.class.to_s.underscore}:#{instance.id}:#{name}:#{instance.updated_at.to_i}:#{style_name}"
        Rails.cache.fetch(cache_key) do
          gem_url(style_name, options)
        end
      end
    end
  end
end
