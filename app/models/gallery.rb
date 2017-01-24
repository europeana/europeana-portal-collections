# frozen_string_literal: true
class Gallery < ActiveRecord::Base
  include HasPublicationStates

  has_many :images, class_name: 'GalleryImage', dependent: :destroy, inverse_of: :gallery
  accepts_nested_attributes_for :images, allow_destroy: true

  translates :title, :description, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  has_paper_trail

  validates :title, presence: true, length: { maximum: 60 }
  validates :description, length: { maximum: 280 }
end
