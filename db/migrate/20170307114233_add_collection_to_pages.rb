class AddCollectionToPages < ActiveRecord::Migration
  def change
    add_reference :pages, :collection, index: true
    add_foreign_key :pages, :collections

    reversible do |change|
      change.up do
        Page::Landing.all.each do |landing_page|
          key = landing_page.slug.split('/').last
          key = key.blank? ? 'all' : key
          collection = Collection.find_by_key(key)
          landing_page.collection = collection
          landing_page.save
        end
      end
    end
  end
end
