# frozen_string_literal: true

class Page
  class Landing < Page
    include IsPermissionable

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

    store_accessor :config, :layout_type

    validates :layout_type, inclusion: { in: :layout_type_enum }
    validates :collection, presence: true, uniqueness: true

    delegate :layout_type_enum, to: :class

    before_create :set_slug, if: :collection

    class << self
      def layout_type_enum
        %w(default browse)
      end

      def home
        find_by_slug('')
      end
    end

    def layout_type
      super || 'default'
    end

    def og_image
      @og_image ||= og_image_from_promo || og_image_from_hero
    end

    private

    def og_image_from_promo
      return unless layout_type == 'browse'
      promo = promotions.find_by(position: 0)
      promo&.file&.url
    end

    def og_image_from_hero
      hero_image&.file&.url
    end

    def set_slug
      new_slug = collection.for_all? ? '' : "collections/#{collection.key}"
      self.slug = new_slug
    end
  end
end
