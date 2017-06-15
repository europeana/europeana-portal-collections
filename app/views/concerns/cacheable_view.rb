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

  # Override this method in view classes to enable body caching
  def body_cache_key
    fail NotImplementedError
  end

  def cacheable?
    return false unless cache_body?

    begin
      body_cache_key
      true
    rescue NotImplementedError
      false
    end
  end
end
