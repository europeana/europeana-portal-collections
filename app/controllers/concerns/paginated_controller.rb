# frozen_string_literal: true

##
# Methods for controllers requiring pagination
module PaginatedController
  extend ActiveSupport::Concern

  class_methods do
    attr_accessor :pagination_per_default
  end

  included do
    self.pagination_per_default ||= 12
    helper_method :pagination_page, :pagination_per
  end

  def pagination_page
    (params[:page] || 1).to_i
  end

  def pagination_per
    (params[:per_page] || self.class.pagination_per_default).to_i
  end
end
