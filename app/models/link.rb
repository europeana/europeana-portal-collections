class Link < ActiveRecord::Base
  belongs_to :link_set, foreign_key: :set_id

  validates :url, presence: true, url: true

  has_paper_trail
end
