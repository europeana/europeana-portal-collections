# frozen_string_literal: true

class Page < ActiveRecord::Base
  include HasPublicationStates
  include HasSettingsAttribute

  belongs_to :hero_image, inverse_of: :page
  belongs_to :banner, inverse_of: :pages

  has_many :element_groups, -> { order(:position) },
           class_name: 'PageElementGroup', dependent: :destroy, inverse_of: :page
  has_many :elements, -> { order(:position) }, through: :element_groups, inverse_of: :page

  has_many :browse_entry_groups, -> { order(:position) }, dependent: :destroy
  has_many :browse_entries, through: :browse_entry_groups

  has_and_belongs_to_many :feeds
  accepts_nested_attributes_for :hero_image, allow_destroy: true
  accepts_nested_attributes_for :element_groups, allow_destroy: true
  accepts_nested_attributes_for :browse_entry_groups, allow_destroy: true

  has_settings :full_width

  delegate :file, to: :hero_image, prefix: true, allow_nil: true
  delegate :settings_full_width_enum, to: :class

  class << self
    def settings_full_width_enum
      %w(0 1)
    end
  end

  has_paper_trail

  translates :title, :body, :strapline, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  default_scope { includes(:translations) }

  validates :slug, uniqueness: true
  validate :total_number_of_browse_entries
  validates :settings_full_width, inclusion: { in: settings_full_width_enum }, allow_nil: true

  scope :static, -> { where(type: nil) }
  scope :primary, -> { static.where('slug <> ? AND slug NOT LIKE ?', '', '%/%') }

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

  def total_number_of_browse_entries
    if browse_entries.size > 6
      errors.add(:browse_entries, 'may not be more than 6 in total')
    end
  end
end
