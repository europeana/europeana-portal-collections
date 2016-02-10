class Page < ActiveRecord::Base
  include HasPublicationStates
  include HasSettingsAttribute

  belongs_to :hero_image, inverse_of: :page
  belongs_to :banner, inverse_of: :pages
  has_many :elements, -> { order(:position) }, class_name: 'PageElement',
    dependent: :destroy, inverse_of: :page
  has_many :browse_entries, through: :elements, source: :positionable,
    source_type: 'BrowseEntry'

  accepts_nested_attributes_for :hero_image, allow_destroy: true
  accepts_nested_attributes_for :browse_entries

  has_settings :full_width

  delegate :file, to: :hero_image, prefix: true, allow_nil: true
  delegate :settings_full_width_enum, to: :class

  class << self
    def settings_full_width_enum
      ['0', '1']
    end
  end

  validates :settings_full_width, inclusion: { in: settings_full_width_enum }, allow_nil: true

  has_paper_trail

  translates :title, :body, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  validates :slug, uniqueness: true
  validates :browse_entries, length: { maximum: 6 }

  scope :static, -> { where(type: nil) }
  scope :primary, -> { static.where('slug <> ? AND slug NOT LIKE ?', '', "%/%") }

  def to_param
    slug
  end

  def parent_slug
    @parent_slug ||= slug.blank? ? nil : slug.split('/')[0..-2].join('/')
  end

  # Gets parent page by slug
  def parent
    @parent ||= parent_slug.blank? ? nil : self.class.static.find_by_slug(parent_slug)
  end

  # Gets child pages by slug
  def children
    @children ||= begin
      if slug.blank?
        self.class.static.none
      else
        self.class.static.where('slug LIKE ? AND slug NOT LIKE ?', "#{slug}/%", "#{slug}/%/%")
      end
    end
  end

  def browse_entry_ids=(ids)
    super

    ids.reject(&:blank?).each_with_index do |id, index|
      element = elements.detect { |e| (e.positionable_type == 'BrowseEntry') && (e.positionable_id == id.to_i) }
      element.remove_from_list
      element.insert_at(index + 1)
    end
  end
end
