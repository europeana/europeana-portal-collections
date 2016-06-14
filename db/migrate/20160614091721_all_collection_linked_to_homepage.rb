class AllCollectionLinkedToHomepage < ActiveRecord::Migration
  def up
    all = Collection.find_or_initialize_by(key: 'home')
    all.key = 'all'
    all.api_params = '*:*'
    all.title = 'All of Europeana'
    all.save
  end

  def down
    home = Collection.find_or_initialize_by(key: 'all')
    home.key = 'home'
    home.api_params = '*:*'
    home.title = 'Home'
    home.save
  end
end
