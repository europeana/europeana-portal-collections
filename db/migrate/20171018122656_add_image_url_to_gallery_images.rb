# frozen_string_literal: true

class AddImageUrlToGalleryImages < ActiveRecord::Migration
  class GalleryImage < ActiveRecord::Base
    validates :gallery_id, presence: true
    validates :europeana_record_id,
              presence: true, format: { with: Europeana::Record::ID_PATTERN }
    validates :image_url, presence: true
  end

  def up
    add_column :gallery_images, :image_url, :text

    GalleryImage.find_in_batches(batch_size: 100) do |batch|
      record_ids = batch.map(&:europeana_record_id)
      api_query = Europeana::Record.search_api_query_for_record_ids(record_ids)
      response = Europeana::API.record.search(query: api_query, profile: 'rich', rows: 100)

      batch.each do |image|
        response_item = response['items'].detect { |item| item['id'] == image.europeana_record_id }
        image.image_url = response_item.nil? ? 'UNKNOWN' : item['edmIsShownBy'].first
        image.save
      end
    end

    change_column :gallery_images, :image_url, :text, null: false
  end

  def down
    remove_column :gallery_images, :image_url
  end
end
