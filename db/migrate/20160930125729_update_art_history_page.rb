# frozen_string_literal: true

class UpdateArtHistoryPage < ActiveRecord::Migration
  def up
    Page.connection.execute("UPDATE pages SET slug = 'collections/art' WHERE slug='collections/art-history'")
  end

  def down
    Page.connection.execute("UPDATE pages SET slug = 'collections/art-history' WHERE slug='collections/art'")
  end
end
