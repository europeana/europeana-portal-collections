class BrowseEntry < ActiveRecord::Base
  include HasPublicationStates
  include HasSettingsAttribute

  has_and_belongs_to_many :collections
  has_many :page_elements, dependent: :destroy, as: :positionable
  has_many :pages, through: :page_elements
  belongs_to :media_object, dependent: :destroy

  has_settings(:category)

  delegate :file, to: :media_object, allow_nil: true

  delegate :settings_category_enum, to: :class

  accepts_nested_attributes_for :media_object, allow_destroy: true

  # Do not re-order these elements!
  # @see http://api.rubyonrails.org/classes/ActiveRecord/Enum.html
  enum subject_type: [:concept, :agent]

  class << self
    def settings_category_enum
      %w(search spotlight)
    end
  end

  validates :settings_category, inclusion: { in: settings_category_enum }, allow_nil: true

  translates :title, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  after_update :touch_pages
  after_touch :touch_pages
  after_destroy :touch_pages

  ##
  # Touch associated pages to invalidate cache
  def touch_pages
    pages.find_each(&:touch)
  end

  def file=(*args)
    (media_object || build_media_object).send(:file=, *args)
  end
end
