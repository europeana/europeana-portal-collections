class BrowseEntry < ActiveRecord::Base
  include HasSettingsAttribute

  belongs_to :page, inverse_of: :browse_entries, touch: true
  belongs_to :media_object, dependent: :destroy, inverse_of: :browse_entry

  has_settings(:category)

  delegate :file, to: :media_object, allow_nil: true

  delegate :settings_category_enum, to: :class

  accepts_nested_attributes_for :media_object, allow_destroy: true

  class << self
    def settings_category_enum
      %w(search spotlight)
    end
  end

  validates :settings_category, inclusion: { in: settings_category_enum }, allow_nil: true

  translates :title, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  def file=(*args)
    (media_object || build_media_object).send(:file=, *args)
  end
end
