class PopulateHomeLandingPageStrapline < ActiveRecord::Migration
  def up
    home = Page::Landing.find_by_slug('')
    unless home.blank?
      I18n.available_locales.each do |locale|
        I18n.locale = locale
        strapline = I18n.t('site.home.strapline', locale: locale)
        unless strapline.blank?
          home.strapline = strapline
          home.save
        end
      end
    end
  end
end
