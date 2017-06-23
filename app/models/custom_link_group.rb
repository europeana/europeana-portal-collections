# frozen_string_literal: true

class CustomLinkGroup < ActiveRecord::Base
  belongs_to :page_landing, class_name: 'Page::Landing', foreign_key: :page_id
  has_many :browse_entries, class_name: 'BrowseEntry', dependent: :destroy
  has_many :custom_links

  class << self
    #remove this section if nothing goes here
  end


  # TODO: these three methods are exactly the same as the ones in facet_link_group.rb, should probably be a concern
  # for determining the collection of the landing page
  def collection_key
    if page_landing.slug.starts_with?('collections/')
      page_landing.slug.split('/')[1]
    end
  end

  # for determining the collection of the landing page
  def collection
    if within_collection?
      @collection = Collection.find_by_key!(page_landing.slug.split('/')[1])
    end
  end

  # for determining whether or not the landing page is for a collection
  def within_collection?
    page_landing.slug.starts_with?('collections/')
  end
end
