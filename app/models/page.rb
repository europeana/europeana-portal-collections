class Page < ActiveRecord::Base
  include HasPublicationStates

  belongs_to :hero_image
  has_many :browse_entries, -> { order(:position) }, dependent: :destroy

  accepts_nested_attributes_for :hero_image, allow_destroy: true
  accepts_nested_attributes_for :browse_entries, allow_destroy: true

  delegate :file, :file=, to: :hero_image, prefix: true
  attr_accessor :delete_file
  before_validation { file.clear if delete_file == '1' }

  has_paper_trail

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  validates :slug, uniqueness: true

  def hero_image(*args)
    super || HeroImage.new
  end
end
