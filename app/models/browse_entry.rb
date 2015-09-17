class BrowseEntry < ActiveRecord::Base
  include HasSettingsAttribute

  belongs_to :page
  belongs_to :media_object, dependent: :destroy

  has_settings(:category)

  delegate :file, :file=, to: :media_object
  attr_accessor :delete_file
  before_validation { self.file.clear if self.delete_file == '1' }
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

  def media_object(*args)
    super || build_media_object
  end
end
