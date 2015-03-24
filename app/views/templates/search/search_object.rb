module Templates
  module Search
    class SearchObject < Stache::Mustache::View
      def pagetitle
        'page title'
      end

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
          document['proxies'][0]['dcTitle']['def']
        end
      end
      
      def doc
        document.as_json.to_s 
      end
      
      private

    end
  end
end
