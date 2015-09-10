class Link < ActiveRecord::Base
  belongs_to :linkable, polymorphic: true

  validates :url, presence: true
  validates :url, url: { allow_local: true }, allow_nil: true

  has_paper_trail

  translates :text
  accepts_nested_attributes_for :translations, allow_destroy: true
end
