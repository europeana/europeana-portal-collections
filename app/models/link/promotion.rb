class Link::Promotion < Link
  include HasSettingsAttribute

  belongs_to :media_object, dependent: :destroy, inverse_of: :promotion
  accepts_nested_attributes_for :media_object, allow_destroy: true

  has_settings(:wide, :category, :class)

  delegate :file, to: :media_object, allow_nil: true

  delegate :settings_category_enum, to: :class
  delegate :settings_wide_enum, to: :class

  class << self
    def settings_category_enum
      %w(collection exhibition new partner featured_site app timeline playlist gallery)
    end

    def settings_wide_enum
      ['0', '1']
    end
  end

  validates :settings_category, inclusion: { in: settings_category_enum }, allow_nil: true, allow_blank: true
  validates :settings_wide, inclusion: { in: settings_wide_enum }, allow_nil: true

  def file=(*args)
    (media_object || build_media_object).send(:file=, *args)
  end
end
