# frozen_string_literal: true
class BrowseEntry < ActiveRecord::Base
  include HasPublicationStates
  include IsPermissionable

  has_and_belongs_to_many :collections
  has_many :page_elements, dependent: :destroy, as: :positionable
  has_many :pages, through: :page_elements

  has_many :group_elements, dependent: :destroy, as: :groupable
  has_many :element_groups, through: :group_elements, source: :groupable, source_type: 'ElementGroup::BrowseEntryGroup',
                            class_name: 'ElementGroup::BrowseEntryGroup', as: :positionable
  has_many :element_group_page_elements, through: :element_groups, source: :page_elements, dependent: :destroy,
                                         as: :positionable
  has_many :element_group_pages, through: :element_group_page_elements, source: :page, class_name: 'Page::Landing'
  belongs_to :media_object, dependent: :destroy

  delegate :file, to: :media_object, allow_nil: true

  accepts_nested_attributes_for :media_object, allow_destroy: true

  validates :subject_type, presence: true, unless: :facet?

  scope :search, -> { where(type: nil) }

  # Do not re-order these elements!
  # @see http://api.rubyonrails.org/classes/ActiveRecord/Enum.html
  enum subject_type: [:topic, :person, :period]

  translates :title, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  default_scope { includes(:translations) }

  after_update :touch_pages
  after_touch :touch_pages
  after_destroy :touch_pages

  def facet?
    false
  end

  ##
  # Touch associated pages to invalidate cache
  def touch_pages
    pages.find_each(&:touch)
    element_group_pages.find_each(&:touch)
  end

  def file=(*args)
    (media_object || build_media_object).send(:file=, *args)
  end
end
