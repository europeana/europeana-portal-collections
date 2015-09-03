class Banner < ActiveRecord::Base
  has_one :link, as: :linkable, dependent: :destroy

  accepts_nested_attributes_for :link

  delegate :url, to: :link, prefix: true
  delegate :text, to: :link, prefix: true

  validates :key, uniqueness: true, allow_nil: true
end
