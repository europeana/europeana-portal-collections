class Banner < ActiveRecord::Base
  include HasPublicationStates

  has_one :link, as: :linkable, dependent: :destroy

  accepts_nested_attributes_for :link

  delegate :url, :url=, :text, :text=, to: :link, prefix: true

  validates :key, uniqueness: true, allow_nil: true

  has_paper_trail

  translates :title, :body
  accepts_nested_attributes_for :translations, allow_destroy: true

  after_initialize do
    build_link if self.link.nil?
  end
end
