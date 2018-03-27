# frozen_string_literal: true

class SeedCollectionTitles < ActiveRecord::Migration
  def up
    Collection.find_each do |collection|
      next unless collection.has_landing_page?

      I18n.available_locales.each do |locale|
        I18n.locale = locale
        title = collection.landing_page_title
        unless title.blank?
          collection.title = title
          collection.save
        end
      end
    end
  end
end
