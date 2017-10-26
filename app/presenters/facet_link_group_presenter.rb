# frozen_string_literal: true

##
# Display logic for facet link groups(facet entry points).
#
# Responsible for generating data hashes for the Mustache templates from
# [Europeana's styleguide](https://github.com/europeana/europeana-styleguide-ruby)
# to display facet entry points on browse based landing pages.
class FacetLinkGroupPresenter < ApplicationPresenter
  include Facet::Labelling
  include ThumbnailHelper
  include UrlHelper

  attr_reader :controller, :blacklight_config, :facet_link_group

  def initialize(facet_link_group, controller, blacklight_config, page = nil)
    @facet_link_group = facet_link_group
    @controller = controller
    @blacklight_config = blacklight_config
    @page = page
  end

  def display
    {
      title: facet_title,
      items: facet_entry_items
    }
  end

  def facet_name
    @facet_name ||= @facet_link_group.facet_field
  end

  def facet_title
    facet_config = blacklight_config.facet_fields[facet_name]
    title = facet_config.respond_to?(:title) ? facet_config.title : facet_label
    title || @facet_link_group.facet_field
  end

  def facet_entry_items
    facet_link_group.browse_entry_facet_entries.map do |entry_point|
      thumb_url = Rails.cache.fetch("facet_link_groups/#{facet_link_group.id}/#{entry_point.id}/thumbnail_url")
      facet_entry_item(entry_point, thumbnail_url_for_edm_preview(thumb_url))
    end
  end

  def facet_entry_item(entry, thumb_url = nil)
    {
      url: browse_entry_path(entry, @page),
      label: facet_item_label(entry.facet_value),
      value: entry.facet_value,
      image_url: thumb_url,
      image_alt: nil
    }
  end

  def respond_to_missing?(method_name, include_private = false)
    controller.respond_to?(method_name) || super
  end

  ##
  # Sends missing method calls to the controller
  def method_missing(method, *args)
    if controller.respond_to?(method)
      controller.send(method, *args)
    else
      super
    end
  end
end
