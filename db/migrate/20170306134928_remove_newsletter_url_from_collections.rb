class RemoveNewsletterUrlFromCollections < ActiveRecord::Migration
  def change
    remove_column :collections, :newsletter_url, :string
  end
end
