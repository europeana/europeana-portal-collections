# frozen_string_literal: true

# TODO: remove settings column once replaced in production by config column
class Page < ActiveRecord::Base
  include HasPublicationStates

  belongs_to :hero_image, inverse_of: :page
  belongs_to :banner, inverse_of: :pages
  has_many :elements, -> { order(:position) },
           class_name: 'PageElement', dependent: :destroy, inverse_of: :page
  has_many :browse_entries, through: :elements, source: :positionable,
                            source_type: 'BrowseEntry'
  has_and_belongs_to_many :feeds
  accepts_nested_attributes_for :hero_image, allow_destroy: true
  accepts_nested_attributes_for :browse_entries

  store_accessor :config, :full_width

  # +link_text+ is only used by +Page::Browse::RecordSets+ but needs to be
  # included here for globalize to be able to translate it
  store_accessor :config, :link_text
  translates :link_text, fallbacks_for_empty_translations: true

  delegate :file, to: :hero_image, prefix: true, allow_nil: true
  delegate :full_width_enum, to: :class

  class << self
    def full_width_enum
      %w(0 1)
    end
  end

  validates :full_width, inclusion: { in: full_width_enum }, allow_nil: true

  has_paper_trail

  translates :title, :body, :strapline, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true
  default_scope { includes(:translations) }

  validates :slug, uniqueness: true
  validate :browse_entries_validation

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
    @parent ||= parent_slug.blank? ? nil : Page.find_by_slug(parent_slug)
  end

  # Gets child pages by slug
  def children
    @children ||= begin
      if slug.blank?
        Page.none
      else
        Page.where('slug LIKE ? AND slug NOT LIKE ?', "#{slug}/%", "#{slug}/%/%")
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

  def browse_entries_validation
    topic_count = 0
    person_count = 0
    period_count = 0
    browse_entries.each do |browse_entry|
      topic_count += 1 if browse_entry.subject_type == 'topic'
      person_count += 1 if browse_entry.subject_type == 'person'
      period_count += 1 if browse_entry.subject_type == 'period'
    end
    unless (topic_count % 3).zero?
      errors.add(:browse_entries, "for topics need to be in groups of 3, you have provided #{topic_count}")
    end
    unless (person_count % 3).zero?
      errors.add(:browse_entries, "for persons need to be in groups of 3, you have provided #{person_count}")
    end
    unless (period_count % 3).zero?
      errors.add(:browse_entries, "for periods need to be in groups of 3, you have provided #{period_count}")
    end
    unless period_count + topic_count + person_count <= 6
      errors.add(:browse_entries, "total count of 'non facet' Type entries need to be equal to 3 or 6.")
    end
  end
end
