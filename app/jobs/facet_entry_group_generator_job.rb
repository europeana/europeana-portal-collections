# frozen_string_literal: true

class FacetEntryGroupGeneratorJob < ApplicationJob
  include ApiQueryingJob

  queue_as :default

  def perform(facet_entry_group_id)
    @facet_entry_group = ElementGroup::FacetEntryGroup.find_by_id(facet_entry_group_id)
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
      @facet_entry_group.facet_entries.where.not(facet_value: facets.map(&:value)).destroy_all
      position = 0
      facets.each do |facet|
        position += 1
        facet_value = facet.value
        facet_entry = @facet_entry_group.facet_entries.where(facet_value: facet_value).first

        thumbnail = @facet_entry_group.thumbnails? ? thumbnail_url_for(facet_value) : nil

        if facet_entry
          set_facet_entry_position(facet_entry, position)
          Rails.cache.write("facet_entry_groups/#{@facet_entry_group.id}/#{facet_entry.id}/thumbnail_url", thumbnail)
          next
        end

        params = {
          facet_value: facet_value,
          title: facet_value,
          file: thumbnail
        }
        new_facet_entry = @facet_entry_group.facet_entries.create!(params)
        set_facet_entry_position(new_facet_entry, position)
        Rails.cache.write("facet_entry_groups/#{@facet_entry_group.id}/#{new_facet_entry.id}/thumbnail_url", thumbnail)
      end
    end
  end

  def set_facet_entry_position(facet_entry, position)
    group_element = facet_entry.group_elements.detect do |e|
      (e.groupable_type == ('BrowseEntry::FacetEntry')) && (e.groupable_id == facet_entry.id)
    end
    group_element.remove_from_list
    group_element.insert_at(position)
  end

  def facet_values_limit
    @facet_entry_group.facet_values_count ? @facet_entry_group.facet_values_count : 6
  end

  def facet_field
    @facet_field ||= @facet_entry_group.facet_field
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
    if @facet_entry_group.within_collection?
      params_hash = @facet_entry_group.collection.api_params_hash
    end
    search_builder.with_overlay_params(params_hash).rows(0).merge(profile: 'facets')
  end

  def first_thumbnail_api_query(facet_value)
    params_hash = { 'qf' => [] }
    if @facet_entry_group.within_collection?
      params_hash = @facet_entry_group.collection.api_params_hash
    end
    params_hash['thumbnail'] = 'true'
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
