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
      },
      fashion: {
        filter: 'culturelover-fashion',
        label: Topic.find_by_slug('fashion').label
      }
    }
  end
end
