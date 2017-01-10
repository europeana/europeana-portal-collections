class Page::Landing < Page
  has_many :credits, -> { order(:position) }, as: :linkable, class_name: 'Link::Credit', dependent: :destroy
  has_many :social_media, -> { order(:position) }, as: :linkable, class_name: 'Link::SocialMedia', dependent: :destroy
  has_many :promotions, -> { order(:position) }, as: :linkable, class_name: 'Link::Promotion', dependent: :destroy

  accepts_nested_attributes_for :credits, allow_destroy: true
  accepts_nested_attributes_for :social_media, allow_destroy: true
  accepts_nested_attributes_for :promotions, allow_destroy: true

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  default_scope { includes(:translations) }

  has_settings :layout_type

  validates :settings_layout_type, inclusion: { in: :settings_layout_type_enum }

  delegate :settings_layout_type_enum, to: :class

  class << self
    def settings_layout_type_enum
      %w(default browse)
    end
  end

  def settings_layout_type
    settings[:layout_type] ? settings[:layout_type] : 'default'
  end
end
