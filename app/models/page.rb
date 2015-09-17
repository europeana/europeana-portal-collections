class Page < ActiveRecord::Base
  include HasPublicationStates

  belongs_to :hero_image
  has_many :browse_entries, -> { order(:position) }, dependent: :destroy

  accepts_nested_attributes_for :hero_image, allow_destroy: true
  accepts_nested_attributes_for :browse_entries, allow_destroy: true

  delegate :file, to: :hero_image, prefix: true, allow_nil: true

  has_paper_trail

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  validates :slug, uniqueness: true

  scope :static, -> { where(type: nil) }
end
