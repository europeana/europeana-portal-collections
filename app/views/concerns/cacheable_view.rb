# frozen_string_literal: true

##
# Methods for caching rendered view content
module CacheableView
  extend ActiveSupport::Concern

  def cached_body
    lambda do |text|
      if cache_body?
        Rails.cache.fetch(cache_key(body_cache_key), expires_in: cache_ttl) { render(text) }
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

  private

  def cache_ttl
    time_now = Time.zone.now
    if site_notice_enabled? && !site_notice_begin.nil? && time_now < site_notice_begin
      # Cache until site notice start time
      site_notice_begin.to_i - time_now.to_i
    elsif site_notice_enabled? && !site_notice_end.nil? && time_now < site_notice_end
      # Cache until site notice end time
      site_notice_end.to_i - time_now.to_i
    else
      24.hours
    end
  end
end
