# frozen_string_literal: true

class ElementGroup::FacetEntryGroup < ElementGroup
  include Blacklight::RequestBuilders

  has_many :facet_entry_elements, -> { order(:position) }, as: :groupable, class_name: 'GroupElement',
           dependent: :destroy
  has_many :facet_entries, through: :facet_entry_elements, source: :groupable,
           source_type: 'BrowseEntry::FacetEntry'

  validates :facet_field, presence: true
  validates :facet_field, inclusion: { in: :facet_field_enum_values }

  accepts_nested_attributes_for :facet_entry_elements
  accepts_nested_attributes_for :facet_entries

  after_save :set_facet_entries

  delegate :facet_field_enum, :facet_field_enum_values, to: :class

  class << self
    # To help with populating CMS
    def facet_field_enum
      PortalController.blacklight_config.facet_fields.keys.each_with_object({}) do |facet_field, h|
        ff = Europeana::Blacklight::Response::Facets::FacetField.new(facet_field, [])
        presenter = FacetPresenter.build(ff, PortalController.new, PortalController.blacklight_config)
        facet_title = presenter.facet_title || facet_field
        h[facet_title] = facet_field
      end
    end

    # To help with populating CMS
    def facet_field_enum_values
      facet_field_enum.values
    end
  end

  # After create/save Job to retrieve all the facet-values
  def set_facet_entries
    FacetLinkGroupGeneratorJob.perform_later(id)
  end

  # for determining the collection of the landing page
  def collection_key
    if page_landing.slug.starts_with?('collections/')
      page_landing.slug.split('/')[1]
    end
  end

  # for determining the collection of the landing page
  def collection
    if within_collection?
      @collection = Collection.find_by_key!(page_landing.slug.split('/')[1])
    end
  end

  # for determining whether or not the landing page is for a collection
  def within_collection?
    page_landing.slug.starts_with?('collections/')
  end
end
