# frozen_string_literal: true

class ElementGroup
  class FacetEntryGroup < ElementGroup
    include Blacklight::RequestBuilders

    has_many :facet_entries, through: :group_elements, source: :groupable,
                             source_type: 'BrowseEntry::FacetEntry'

    validates :facet_field, presence: true
    validates :facet_field, inclusion: { in: :facet_field_enum_values }

    accepts_nested_attributes_for :group_elements
    accepts_nested_attributes_for :facet_entries

    after_save :set_facet_entries

    delegate :facet_field_enum, :facet_field_enum_values, to: :class

    def facet_entry_ids=(ids)
      super

      ids.reject(&:blank?).each_with_index do |id, index|
        element = group_elements.detect { |e| (e.groupable_type == 'BrowseEntry') && (e.groupable_id == id.to_i) }
        element.remove_from_list
        element.insert_at(index + 1)
      end
    end

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
      FacetEntryGroupGeneratorJob.perform_later(id)
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

    def page_landing
      @page_landing ||= begin
        pages.where(type == 'Page::Landing').first
      end
    end
  end
end
