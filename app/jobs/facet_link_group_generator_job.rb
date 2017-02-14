# frozen_string_literal: true

class FacetLinkGroupGeneratorJob < ApplicationJob
  include ApiQueryingJob

  queue_as :default

  def perform(facet_link_group_id)
    @facet_link_group = FacetLinkGroup.find_by_id(facet_link_group_id)
    set_facet_entries
  end

  def blacklight_config
    @blacklight_config ||= PortalController.blacklight_config.deep_dup.tap do |blacklight_config|
      field_config = blacklight_config.facet_fields[facet_field]
      field_config[:split] = false
      blacklight_config.facet_fields = { facet_field => field_config }
    end
  end

  protected

  def set_facet_entries
    facets = displayable_facet_values.first(facet_values_limit)
    BrowseEntry::FacetEntry.transaction do
      @facet_link_group.browse_entry_facet_entries.where.not(facet_value: facets.map(&:value)).destroy_all
      facets.each do |facet|
        facet_entry = @facet_link_group.browse_entry_facet_entries.where(facet_value: facet.value).first
        facet_value = facet.value

        thumbnail = @facet_link_group.thumbnails? ? thumbnail_url_for(facet_value) : nil

        if facet_entry
          Rails.cache.write("facet_link_groups/#{@facet_link_group.id}/#{facet_entry.id}/thumbnail_url", thumbnail)
          next
        end

        params = {
          facet_value: facet_value,
          title: facet_value,
          file: thumbnail
        }
        new_entry = @facet_link_group.browse_entry_facet_entries.create!(params)
        Rails.cache.write("facet_link_groups/#{@facet_link_group.id}/#{new_entry.id}/thumbnail_url", thumbnail)
      end
    end
  end

  def facet_values_limit
    @facet_link_group.facet_values_count ? @facet_link_group.facet_values_count : 6
  end

  def facet_field
    @facet_field ||= @facet_link_group.facet_field
  end

  def facet_values_response
    repository.search(facet_values_api_query)
  end

  def displayable_facet_values
    fields = facet_values_response['facets'].first['fields']
    items = fields.map do |field|
      Europeana::Blacklight::Response::Facets::FacetItem.new(value: field['label'], hits: field['count'])
    end
    ff = Europeana::Blacklight::Response::Facets::FacetField.new(facet_field, items)
    FacetPresenter.build(ff, PortalController.new, blacklight_config).items_to_display
  end

  def facet_values_api_query
    params_hash = {}
    if @facet_link_group.within_collection?
      params_hash = @facet_link_group.collection.api_params_hash
    end
    search_builder.with_overlay_params(params_hash).rows(0).merge(profile: 'facets')
  end

  def first_thumbnail_api_query(facet_value)
    params_hash = { 'qf' => [] }
    if @facet_link_group.within_collection?
      params_hash = @facet_link_group.collection.api_params_hash
    end
    params_hash['qf'] << "(#{facet_field}:\"#{facet_value}\")"
    search_builder.with_overlay_params(params_hash).rows(20)
  end

  def thumbnail_response(facet_value)
    repository.search(first_thumbnail_api_query(facet_value))
  end

  def thumbnail_url_for(facet_value)
    search_results = thumbnail_response(facet_value)
    items = search_results['items']
    items.each do |item|
      next if !item['edmPreview'] || item['edmPreview'].count.zero?
      return item['edmPreview'].first
    end
    # no item with a preview, just return nil
    nil
  end
end
