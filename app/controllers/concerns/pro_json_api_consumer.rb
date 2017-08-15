# frozen_string_literal: true

module ProJsonApiConsumer
  extend ActiveSupport::Concern

  included do
    helper_method :pro_json_api_theme_filters, :pro_json_api_selected_theme
  end

  protected

  def pro_json_api_filters
    {
      tags: (pro_json_api_theme_filters[pro_json_api_selected_theme] || {})[:filter]
    }
  end

  def pro_json_api_selected_theme
    (params[:theme] || 'all').to_sym
  end

  def pro_json_api_theme_filters
    {
      all: {
        filter: 'culturelover',
        label: t('global.actions.filter-all')
      }
    }.merge(pro_json_api_theme_filters_from_collections)
  end

  def pro_json_api_whitelisted_collections
    displayable_collections
  end

  def pro_json_api_theme_filters_from_collections
    pro_json_api_whitelisted_collections.sort_by { |collection| collection.landing_page.title }.each_with_object({}) do |collection, filters|
      filters[collection.key.downcase.to_sym] = {
        filter: "culturelover-#{collection.key.downcase}",
        label: collection.landing_page.title
      }
    end
  end
end
