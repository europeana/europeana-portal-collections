# frozen_string_literal: true
class GalleryImage < ActiveRecord::Base
  belongs_to :gallery, inverse_of: :images

  validates :gallery, presence: true
  validates :record_url, presence: true
  validates :position, uniqueness: { scope: :gallery_id }
end
