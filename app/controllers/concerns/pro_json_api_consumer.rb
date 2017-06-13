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
    }.merge(pro_json_api_theme_filters_from_topics)
  end

  def pro_json_api_whitelisted_topics
    Topic.where(slug: %w(
      archaeology architecture art fashion food-and-drink history literature
      maps-and-cartography migration music natural-history photography world-war-i
    ))
  end

  def pro_json_api_theme_filters_from_topics
    pro_json_api_whitelisted_topics.sort_by(&:label).each_with_object({}) do |topic, filters|
      filters[topic.slug.to_sym] = {
        filter: "culturelover-#{topic.slug}",
        label: topic.label
      }
    end
  end
end
