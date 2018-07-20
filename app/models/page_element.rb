# frozen_string_literal: true

class PageElement < ActiveRecord::Base
  belongs_to :page, inverse_of: :elements, touch: true
  belongs_to :positionable, polymorphic: true
  acts_as_list scope: %i(page positionable)

  after_save do
    page.touch
  end

  after_touch do
    page.touch
  end
end
