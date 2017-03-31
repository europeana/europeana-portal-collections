# frozen_string_literal: true
module ProJsonApiConsumer
  extend ActiveSupport::Concern

  included do
    before_action :assign_pro_json_api_theme_vars, only: :index
  end

  protected

  def assign_pro_json_api_theme_vars
    @theme_filters = pro_json_api_theme_filters
    @selected_theme = pro_json_api_theme
  end

  def pro_json_api_filters
    {
      tags: (pro_json_api_theme_filters[pro_json_api_theme] || {})[:filter]
    }
  end

  def pro_json_api_theme
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
