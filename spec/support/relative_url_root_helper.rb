module RelativeUrlRootHelper
  def relative_url_root
    ENV['RAILS_RELATIVE_URL_ROOT'] || ''
  end
end
