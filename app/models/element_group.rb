# frozen_string_literal: true

##
# A group of page elements on one page
#
# The 'ElementGroup' is itself a page element, in order to be 'positionable'
# however the type of the individual elements that make up the group is defined
# in inherited classes. For example see /element_group/browse_entry_group.rb
#
class ElementGroup < ActiveRecord::Base
  has_many :page_elements, dependent: :destroy, as: :positionable
  has_many :pages, through: :page_elements

  has_many :elements, -> { order(:position) },
           class_name: 'GroupElement', dependent: :destroy, inverse_of: :element_group

  validates :pages, length: { minimum: 1, maximum: 1 }

  translates :title, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  accepts_nested_attributes_for :page_elements, allow_destroy: true
  accepts_nested_attributes_for :pages
  default_scope { includes(:translations) }

  accepts_nested_attributes_for :elements, allow_destroy: true

  acts_as_list scope: :page
end