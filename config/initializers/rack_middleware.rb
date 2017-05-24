# frozen_string_literal: true

require 'rack/enforce_http_host'

# Rack middleware configuration
Rails.application.configure do
  config.middleware.use Rack::EnforceHttpHost if ENV.key?('HTTP_HOST')

  # Compress HTTP responses
  config.middleware.use Rack::Deflater unless ENV['DISABLE_RACK_HTML_DEFLATER']

  # Minify HTML
  unless ENV['DISABLE_RACK_HTML_COMPRESSOR'] || !defined?(HtmlCompressor)
    config.middleware.use HtmlCompressor::Rack,
                          enabled: true,
                          remove_multi_spaces: true,
                          remove_comments: true,
                          remove_intertag_spaces: false,
                          remove_quotes: false,
                          compress_css: false,
                          compress_javascript: false,
                          simple_doctype: false,
                          remove_script_attributes: false,
                          remove_style_attributes: false,
                          remove_link_attributes: false,
                          remove_form_attributes: false,
                          remove_input_attributes: false,
                          remove_javascript_protocol: false,
                          remove_http_protocol: false,
                          remove_https_protocol: false,
                          preserve_line_breaks: false,
                          simple_boolean_attributes: false,
                          compress_js_templates: false
  end
end
