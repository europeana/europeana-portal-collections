class Link < ActiveRecord::Base
  validates :url, presence: true, url: true

  has_paper_trail
end
