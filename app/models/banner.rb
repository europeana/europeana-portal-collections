class Banner < ActiveRecord::Base
  has_one :link, as: :linkable, dependent: :destroy

  accepts_nested_attributes_for :link

  delegate :url, :url=, :text, :text=, to: :link, prefix: true

  validates :key, uniqueness: true, allow_nil: true

  after_initialize do
    build_link if self.link.nil?
  end
end
