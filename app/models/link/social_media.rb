class Link::SocialMedia < Link
  def facebook?
    url_in_domain?('facebook.com')
  end

  def googleplus?
    url_in_domain?('plus.google.com')
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
end
