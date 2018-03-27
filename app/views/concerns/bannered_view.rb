# frozen_string_literal: true

##
# Pages waving banners
module BanneredView
  extend ActiveSupport::Concern

  protected

  def page_banner(id = nil)
    banner = id.nil? ? Banner.find_by_default(true) : Banner.find(id)
    return nil unless devise_user.can?(:show, banner)
    banner
  end

  def banner_content(id = nil)
    banner = page_banner(id)
    return nil if banner.nil?

    {
      title: banner.title,
      text: banner.body,
      cta_url: banner.link.present? ? banner.link.url : nil,
      cta_text: banner.link.present? ? banner.link.text : nil
    }
  end
end
