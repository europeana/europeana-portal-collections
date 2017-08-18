# frozen_string_literal: true

##
# A group of page elements on one page
#
# The 'ElementGroup' is itself a page element, in order to be 'positionable'
# however the type of the individual elements that make up the group is defined
# in inherited classes. For example see /element_group/browse_entry_group.rb
#
class ElementGroup < ActiveRecord::Base
  has_one :page_element, dependent: :destroy, as: :positionable
  belongs_to :page, through: :page_element
  has_many :elements, -> { order(:position) },
           class_name: 'GroupElement', inverse_of: :group, dependent: :destroy

  validates :page_id, presence: true

  translates :title, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  default_scope { includes(:translations) }

  accepts_nested_attributes_for :elements, allow_destroy: true

  acts_as_list scope: :page
end