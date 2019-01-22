# frozen_string_literal: true

module HasExternalUrls
  extend ActiveSupport::Concern

  def url_in_domain?(domain)
    !(url =~ %r(://([^/]+\.)?#{domain}/)).nil?
  end

  def facebook?
    url_in_domain?('facebook.com')
  end

  def instagram?
    url_in_domain?('instagram.com')
  end

  def linkedin?
    url_in_domain?('linkedin.com')
  end

  def pinterest?
    url_in_domain?('pinterest.com')
  end

  def soundcloud?
    url_in_domain?('soundcloud.com')
  end

  def tumblr?
    url_in_domain?('tumblr.com')
  end

  def twitter?
    url_in_domain?('twitter.com')
  end

  def europeana_blog?
    url_in_domain?('blog.europeana.eu')
  end

  def pro_blog?
    !(url =~ %r(://([^/]+\.)?europeana.eu/portal/([a-z]{2}/)?blogs\.rss)).nil?
  end

  def pro_events?
    !(url =~ %r(://([^/]+\.)?europeana.eu/portal/([a-z]{2}/)?events\.rss)).nil?
  end
end
