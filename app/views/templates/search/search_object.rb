module Templates
  module Search
    class SearchObject < Stache::Mustache::View
      
      def back_link
         link_back_to_catalog(label: 'return to search results')
      end
      
      def prev_link
        link_to_previous_document(@previous_document)
      end

      def next_link
        link_to_next_document(@next_document)
      end

      def links
        res = {
          :download  => document.is_a?(Blacklight::Document) ? document.get('europeanaAggregation.edmPreview') : ''
        }
      end
      
      # Object data - needs grouped
      
      def edmPreview
        if document.is_a?(Blacklight::Document)
          document.get('europeanaAggregation.edmPreview')
        end
      end
      
      def edmDatasetName
        document['edmDatasetName'] 
      end
      
      def type
        document['type'] 
      end
      
      def title
        if defined?(document['proxies'])
          document['proxies'][0]['dcTitle']['def'].join
        end
      end

      def rights
        if defined?(document['aggregations'])
          document['aggregations'][0]['edmRights']['def'].join
        end
      end

      # All
      
      def doc
        document.as_json.to_s 
      end
      
      private

    end
  end
end
