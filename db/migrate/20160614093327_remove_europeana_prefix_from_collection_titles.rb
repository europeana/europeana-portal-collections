class RemoveEuropeanaPrefixFromCollectionTitles < ActiveRecord::Migration
  def up
    Collection.where("key IS NOT NULL AND key <> ''").find_each do |collection|
      I18n.available_locales.each do |locale|
        I18n.locale = locale
        if !collection.title.blank? && collection.title.starts_with?('Europeana ')
          collection.title.sub!(/\AEuropeana /, '')
          collection.save
        end
      end
    end
  end
end
