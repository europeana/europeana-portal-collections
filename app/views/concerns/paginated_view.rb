# frozen_string_literal: true
module PaginatedView
  extend ActiveSupport::Concern

  protected

  def paginated_set_range(current_page, per_page, total)
    result_number_from = ((current_page - 1) * per_page) + 1
    result_number_to   = [result_number_from + per_page - 1, total].min
    result_number_from.to_s + ' - ' + result_number_to.to_s
  end
end
