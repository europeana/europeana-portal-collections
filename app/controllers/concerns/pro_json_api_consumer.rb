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

  def pro_json_api_theme_filters_from_topics
    Topic.all.sort_by { |topic| topic.label }.each_with_object({}) do |topic, filters|
      filters[topic.slug.to_sym] = {
        filter: "culturelover-#{topic.slug}",
        label: topic.label
      }
    end
  end
end
