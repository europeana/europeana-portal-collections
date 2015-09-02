class Link < ActiveRecord::Base
  belongs_to :link_set, foreign_key: :set_id
  belongs_to :linkable, polymorphic: true

  validates :url, presence: true
  validates :url, url: { allow_local: true }, allow_nil: true

  has_paper_trail
end
