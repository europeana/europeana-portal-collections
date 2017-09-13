# frozen_string_literal: true

module ThumbnailHelper
  include ApiHelper

  def thumbnail_url_for_edm_preview(edm_preview, **options)
    options.reverse_merge!(generic: false, source: :api)
    url_options = options.except(:generic, :source)

    return nil if edm_preview.blank? && !options[:generic]

    case options[:source]
    when :s3
      s3_thumbnail_url_for_edm_preview(edm_preview, **url_options)
    else
      api_thumbnail_url_for_edm_preview(edm_preview, **url_options)
    end
  end

  def api_thumbnail_url_for_edm_preview(edm_preview, **options)
    query = if edm_preview.blank?
              {}
            else
              edm_preview_uri = URI.parse(edm_preview)
              Rack::Utils.parse_query(edm_preview_uri.query).symbolize_keys
            end

    api_thumbnail_url(query.reverse_merge(options))
  end

  def api_thumbnail_url(**options)
    options = thumbnail_url_options_with_size(options)

    uri = URI.parse(api_url)
    uri.path = uri.path + '/v2/thumbnail-by-url.json'

    query = options.dup.except(:size)
    query[:size] = "w#{options[:size]}"

    uri.query = query.to_query
    uri.to_s
  end

  # TODO: remove this when thumbnail API performs well enough for good galleries UX
  def s3_thumbnail_url_for_edm_preview(edm_preview, **options)
    return nil if edm_preview.blank?

    options = thumbnail_url_options_with_size(options)

    uri = CGI.parse(URI.parse(edm_preview).query)['uri'].first
    resource_size = options[:size] == 400 ? 'LARGE' : 'MEDIUM'
    resource_path = Digest::MD5.hexdigest(uri) + '-' + resource_size
    'https://europeana-thumbnails-production.s3.amazonaws.com/' + resource_path
  end

  def thumbnail_url_options_with_size(options)
    options.reverse_merge!(size: 400)
    if options[:size] == 'LARGE'
      options[:size] = 400
    elsif options[:size] == 'MEDIUM'
      options[:size] = 200
    end
    options
  end
end
