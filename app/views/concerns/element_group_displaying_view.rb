# frozen_string_literal: true

# ##
# For views needing to display grouped elements
module ElementGroupDisplayingView
  extend ActiveSupport::Concern

  protected

  ##
  # @param page [Page]
  def grouped_elements_grouped(page)

    page.element_groups.map do |element_group|
      puts "element_group: #{element_group}"
      presenter_class = (element_group.type.gsub('ElementGroup::', '') + 'Presenter').constantize
      presenter_class.new(element_group, controller, blacklight_config, page).display
    end
  end
end
