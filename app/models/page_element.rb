class PageElement < ActiveRecord::Base
  belongs_to :page, inverse_of: :elements, touch: true
  belongs_to :positionable, polymorphic: true
  acts_as_list scope: [:page, :positionable]
end
