class Page::Landing < Page
  belongs_to :collection
  has_many :credits, -> { order(:position) }, as: :linkable, class_name: 'Link::Credit', dependent: :destroy
  has_many :social_media, -> { order(:position) }, as: :linkable, class_name: 'Link::SocialMedia', dependent: :destroy
  has_many :promotions, -> { order(:position) }, as: :linkable, class_name: 'Link::Promotion', dependent: :destroy
  has_many :facet_entries, through: :facet_link_groups, source: :browse_entry_facet_entries
  has_many :facet_link_groups, class_name: 'FacetLinkGroup', foreign_key: :page_id, dependent: :destroy

  accepts_nested_attributes_for :facet_link_groups, allow_destroy: true
  accepts_nested_attributes_for :credits, allow_destroy: true
  accepts_nested_attributes_for :social_media, allow_destroy: true
  accepts_nested_attributes_for :promotions, allow_destroy: true

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  default_scope { includes(:translations) }

  has_settings :layout_type

  validates :settings_layout_type, inclusion: { in: :settings_layout_type_enum }
  validates :collection, presence: true, uniqueness: true

  delegate :settings_layout_type_enum, to: :class

  before_create :set_slug

  class << self
    def settings_layout_type_enum
      %w(default browse)
    end
  end

  def settings_layout_type
    settings[:layout_type] ? settings[:layout_type] : 'default'
  end

  private

  def set_slug
    if collection
      new_slug = collection.key == 'all' ? '' : "collections/#{collection.key}"
      self.slug = new_slug
    end
  end
end
