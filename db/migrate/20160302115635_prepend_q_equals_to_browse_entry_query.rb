# frozen_string_literal: true

class PrependQEqualsToBrowseEntryQuery < ActiveRecord::Migration
  def up
    BrowseEntry.find_each do |be|
      be.query = 'q=' + be.query
      be.save
    end
  end

  def down
    BrowseEntry.find_each do |be|
      be.query.sub!(/\Aq=/, '')
      be.save
    end
  end
end
