# frozen_string_literal: true

class RenameChannelsToCollections < ActiveRecord::Migration
  def up
    rename_table 'channels', 'collections'
    Link::Promotion.find_each do |link|
      if link.settings[:category] == 'channel'
        link.settings[:category] = 'collection'
        link.save
      end
    end
  end

  def down
    rename_table 'collections', 'channels'
    Link::Promotion.find_each do |link|
      if link.settings[:category] == 'collection'
        link.settings[:category] = 'channel'
        link.save
      end
    end
  end
end
