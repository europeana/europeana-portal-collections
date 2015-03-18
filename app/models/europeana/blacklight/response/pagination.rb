require 'kaminari'

module Europeana
  module Blacklight
    class Response
      ##
      # Pagination for{Europeana::Blacklight::Response}
      #
      # Based on {Blacklight::SolrResponse::Pagination} v5.10.2
      module Pagination
        include Kaminari::PageScopeMethods
        include Kaminari::ConfigurationMethods::ClassMethods

        def limit_value
          rows
        end

        def offset_value
          start
        end

        def total_count
          total
        end

        def model_name
          return unless docs.present? && docs.first.respond_to?(:model_name)
          docs.first.model_name
        end

        def next_page
          current_page + 1 unless last_page?
        end

        def prev_page
          current_page - 1 unless first_page?
        end
      end
    end
  end
end
