class LandingPage < ActiveRecord::Base
  belongs_to :channel
  belongs_to :hero_image
  accepts_nested_attributes_for :hero_image
  has_and_belongs_to_many :credits, class_name: 'Link', dependent: :destroy
  accepts_nested_attributes_for :credits

  delegate :file, to: :hero_image, prefix: true

  validates :channel_id, uniqueness: true

  has_paper_trail
end
