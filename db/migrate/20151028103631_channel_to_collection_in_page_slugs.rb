# frozen_string_literal: true

class ChannelToCollectionInPageSlugs < ActiveRecord::Migration
  def up
    Page.find_each do |page|
      page.slug.sub!(/^channels\//, 'collections/')
      page.save
    end
  end

  def down
    Page.find_each do |page|
      page.slug.sub!(/^collections\//, 'channels/')
      page.save
    end
  end
end
