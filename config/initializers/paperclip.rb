# frozen_string_literal: true

# Relative URL root interpolation used in filesystem URL paths
# @see /deploy/development/config/paperclip.yml
Paperclip.interpolates :rails_relative_url_root do |_attachment, _style|
  Rails.application.config.relative_url_root
end

# Basic Paperclip file storage settings
Paperclip::Attachment.default_options.merge!(
  path_prefix: '',
  url_prefix: '',
  path: ':path_prefix:class/:id_partition/:attachment/:fingerprint.:style.:extension',
  url: ':url_prefix:class/:id_partition/:attachment/:fingerprint.:style.:extension',
  image_optimizer: { jpegoptim: { allow_lossy: true, max_quality: 80 }, jpegrecompress: { allow_lossy: true, quality: 2 } },
  styles: { small: '200>', medium: '400>', large: '600>', xl: '1000>', full: '' }, # max-width
  default_style: :full
)

# Load settings from paperclip.yml config file if present
Paperclip::Attachment.default_options.merge! begin
  paperclip_config = Rails.application.config_for(:paperclip)
  fail RuntimeError unless paperclip_config.present?
  paperclip_config.deep_symbolize_keys
rescue RuntimeError
  {}
end

Paperclip.interpolates :path_prefix do |attachment, style|
  path_prefix = Paperclip::Interpolations.interpolate(Paperclip::Attachment.default_options[:path_prefix], attachment, style)
  path_prefix << '/' unless path_prefix.blank? || path_prefix.ends_with?('/')
  path_prefix
end

Paperclip.interpolates :url_prefix do |attachment, style|
  url_prefix = Paperclip::Interpolations.interpolate(Paperclip::Attachment.default_options[:url_prefix], attachment, style)
  url_prefix << '/' unless url_prefix.blank? || url_prefix.ends_with?('/')
  url_prefix
end

# Interpolation for data provider org ID
Paperclip.interpolates :data_provider_org_id do |attachment, _style|
  attachment.instance.data_provider.org_id
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
