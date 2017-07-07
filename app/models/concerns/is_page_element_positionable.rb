# frozen_string_literal: true

module IsPageElementPositionable
  extend ActiveSupport::Concern

  included do
    has_many :page_elements, dependent: :destroy, as: :positionable
    has_many :page_element_groups, through: :page_elements, source: :group
    has_many :pages, through: :page_element_groups

    after_save :touch_page_elements
    after_touch :touch_page_elements
    after_destroy :touch_page_elements
  end

  protected

  ##
  # Touch associated page elements
  def touch_page_elements
    page_elements.find_each(&:touch)
  end
end
