# frozen_string_literal: true
##
# Methods for caching rendered view content
module CacheableView
  extend ActiveSupport::Concern

  def cached_body
    lambda do |text|
      if cache_body?
        Rails.cache.fetch(cache_key(body_cache_key), expires_in: 24.hours) { render(text) }
      else
        render(text)
      end
    end
  end

  def cached_body_content
    Rails.cache.fetch(cache_key(body_cache_key))
  end

  def title_from_cached_body
    title = cached_body_content.match(%r{<div class="title text-centre">(.*?)</div>})[1]
    CGI.unescapeHTML(title)
  end

  # Override this method in view classes to enable body caching
  def body_cache_key
    fail NotImplementedError
  end
end
