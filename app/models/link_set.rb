class LinkSet < ActiveRecord::Base
  has_many :links, foreign_key: :set_id, dependent: :destroy

  accepts_nested_attributes_for :links
end
