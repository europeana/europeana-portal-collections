# frozen_string_literal: true
##
# Filtering by theme
module ThemeFilterableView
  extend ActiveSupport::Concern

  protected

  def theme_filter_options
    theme_options = theme_filters.map { |key, data| { label: data[:label], value: key } }.tap do |options|
      selected_option = options.delete(options.detect { |option| option[:value] == selected_theme })
      options.unshift(selected_option.merge(selected: true)) unless selected_option.nil?
    end

    {
      filter_name: 'theme',
      options: theme_options
    }
  end
end
