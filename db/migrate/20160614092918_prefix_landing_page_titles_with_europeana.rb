class PrefixLandingPageTitlesWithEuropeana < ActiveRecord::Migration
  def up
    Page::Landing.where("slug IS NOT NULL AND slug <> ''").find_each do |page|
      I18n.available_locales.each do |locale|
        I18n.locale = locale
        unless page.title.blank? || page.title.starts_with?('Europeana ')
          page.title = "Europeana #{page.title}"
          page.save
        end
      end
    end
  end
end
