# frozen_string_literal: true

class RemoveNewsletterUrlFromCollections < ActiveRecord::Migration
  def change
    remove_column :collections, :newsletter_url, :string
  end
end
