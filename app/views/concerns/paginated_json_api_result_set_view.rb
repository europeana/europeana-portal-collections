# frozen_string_literal: true
##
# Pagination of JSON API result sets
#
# Including views need to implement `paginated_set`.
module PaginatedJsonApiResultSetView
  extend ActiveSupport::Concern
  include PaginatedView

  protected

  def pagination_current_page
    mustache[:pagination_current_page] ||= begin
      # JsonApiClient::ResultSet#current_page always returns 1 with
      # `paginated_set.current_page`

      # Get it out of the controller-assigned var instead
      @pagination_page
    end
  end

  def pagination_per_page
    mustache[:pagination_per_page] ||= begin
      # JsonApiClient::ResultSet#per_page always returns number in *this* page
      # with `paginated_set.per_page`

      # Get it out of the controller-assigned var instead
      @pagination_per
    end
  end

  def pagination_total
    mustache[:pagination_total] ||= begin
      # JsonApiClient::ResultSet#total_count always returns number in *this* page
      # with `paginated_set.total_pages`

      # Get it from JSON API meta data instead
      if paginated_set.respond_to?(:meta) && paginated_set.meta.respond_to?(:total)
        paginated_set.meta.total
      else
        0
      end
    end
  end

  def pagination_total_pages
    mustache[:pagination_total_pages] ||= begin
      # JsonApiClient::ResultSet#total_pages always returns 1 with
      # `paginated_set.total_pages`

      # Calculate it ourselves instead
      (pagination_total / pagination_per_page) +
        ((pagination_total / pagination_per_page).zero? ? 0 : 1)
    end
  end
end
