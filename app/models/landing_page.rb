class LandingPage < ActiveRecord::Base
  belongs_to :channel
  belongs_to :hero_image
  belongs_to :credits, class_name: 'LinkSet', dependent: :destroy, foreign_key: :credits_id
  belongs_to :social_media, class_name: 'LinkSet', dependent: :destroy, foreign_key: :social_media_id

  has_many :credit_links, through: :credits, source: :links
  has_many :social_media_links, through: :social_media, source: :links

  accepts_nested_attributes_for :hero_image
  accepts_nested_attributes_for :credits
  accepts_nested_attributes_for :credit_links
  accepts_nested_attributes_for :social_media
  accepts_nested_attributes_for :social_media_links

  delegate :file, to: :hero_image, prefix: true
  delegate :links, to: :credits, prefix: :credit
  delegate :links, to: :social_media, prefix: true

  validates :channel_id, uniqueness: true

  has_paper_trail
end
