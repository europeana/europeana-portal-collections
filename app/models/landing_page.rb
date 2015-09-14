class LandingPage < ActiveRecord::Base
  include HasPublicationStates

  belongs_to :channel
  belongs_to :hero_image

  has_many :credits, -> { order(:position) }, as: :linkable, class_name: 'Link::Credit', dependent: :destroy
  has_many :social_media, -> { order(:position) }, as: :linkable, class_name: 'Link::SocialMedia', dependent: :destroy
  has_many :promotions, -> { order(:position) }, as: :linkable, class_name: 'Link::Promotion', dependent: :destroy
  has_many :browse_entries, -> { order(:position) }, dependent: :destroy

  accepts_nested_attributes_for :hero_image, allow_destroy: true
  accepts_nested_attributes_for :credits, allow_destroy: true
  accepts_nested_attributes_for :social_media, allow_destroy: true
  accepts_nested_attributes_for :promotions, allow_destroy: true
  accepts_nested_attributes_for :browse_entries, allow_destroy: true

  delegate :file, :file=, to: :hero_image, prefix: true
  attr_accessor :delete_file
  before_validation { file.clear if delete_file == '1' }

  validates :channel_id, uniqueness: true, allow_nil: true

  has_paper_trail

  def hero_image(*args)
    super || HeroImage.new
  end
end
