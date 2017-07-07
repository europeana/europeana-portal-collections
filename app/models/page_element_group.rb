# frozen_string_literal: true

##
# A group of page elements on one page
class PageElementGroup < ActiveRecord::Base
  belongs_to :page, touch: true, inverse_of: :element_groups
  has_many :elements, -> { order(:position) },
           class_name: 'PageElement', inverse_of: :group, dependent: :destroy

  validates :page_id, presence: true

  translates :title, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  default_scope { includes(:translations) }

  accepts_nested_attributes_for :elements, allow_destroy: true

  acts_as_list scope: :page
end
