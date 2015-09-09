class LandingPage < ActiveRecord::Base
  belongs_to :channel
  belongs_to :hero_image
  
  has_many :credits, as: :linkable, class_name: 'Link::Credit', dependent: :destroy
  has_many :social_media, as: :linkable, class_name: 'Link::SocialMedia', dependent: :destroy
  has_many :promotions, as: :linkable, class_name: 'Link::Promotion', dependent: :destroy
  has_many :browse_entries, dependent: :destroy

  accepts_nested_attributes_for :hero_image
  accepts_nested_attributes_for :credits
  accepts_nested_attributes_for :social_media
  accepts_nested_attributes_for :promotions
  accepts_nested_attributes_for :browse_entries

  delegate :file, to: :hero_image, prefix: true

  validates :channel_id, uniqueness: true, allow_nil: true

  has_paper_trail

  after_initialize do
    build_hero_image if self.hero_image.nil?
  end
end
