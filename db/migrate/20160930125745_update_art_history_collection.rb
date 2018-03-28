# frozen_string_literal: true

class UpdateArtHistoryCollection < ActiveRecord::Migration
  def up
    Collection.connection.execute("UPDATE collections SET key = 'art' WHERE key ='art-history'")
  end

  def down
    Collection.connection.execute("UPDATE collections SET key = 'art-history' WHERE key ='art'")
  end
end
