# frozen_string_literal: true

class AddEdmIsShownByToGalleryImages < ActiveRecord::Migration
  class GalleryImage < ActiveRecord::Base
    validates :gallery_id, presence: true
    validates :europeana_record_id,
              presence: true, format: { with: Europeana::Record::ID_PATTERN }
    validates :edm_is_shown_by, presence: true

    def set_edm_is_shown_by
      api_query = Europeana::Record.search_api_query_for_record_ids([europeana_record_id])
      record = Europeana::API.record.search(query: api_query, profile: 'rich', rows: 1)['items'].first
      self.edm_is_shown_by = record['edmIsShownBy'].first
      save
    rescue
      delete
    end
  end

  def up
    add_column :gallery_images, :edm_is_shown_by, :text

    GalleryImage.all.each(&:set_edm_is_shown_by)

    change_column :gallery_images, :edm_is_shown_by, :text, null: false
  end

  def down
    remove_column :gallery_images, :edm_is_shown_by
  end
end
