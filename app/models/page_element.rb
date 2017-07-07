# frozen_string_literal: true

# TODO: remove page_id column once `PageElementGroup` propagated to production
class PageElement < ActiveRecord::Base
  belongs_to :group, class_name: 'PageElementGroup', foreign_key: :page_element_group_id,
                     touch: true, inverse_of: :elements
  has_one :page, through: :group, inverse_of: :elements
  belongs_to :positionable, polymorphic: true
  acts_as_list scope: [:group, :positionable]
end
