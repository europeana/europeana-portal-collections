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
          :download  => document.get('europeanaAggregation.edmPreview')
        }
      end

      # Object data - needs grouped
      def data
        {
          :agent_pref_label => document.get('agents.prefLabel'),

          :dc_description => document.get('proxies.dcDescription'),
          :dc_type => document.get('proxies.dcType'),
          :dc_creator => document.get('proxies.dcCreator'),

          :dc_format => document.get('proxies.dcFormat'),
          :dc_identifier => document.get('proxies.dcIdentifier'),

          :dc_terms_created => document.get('proxies.dctermsCreated'),
           
          :dc_terms_created_web => document.get('aggregations.webResources.dctermsCreated'),

          :dc_terms_extent => document.get('proxies.dctermsExtent'),
          :dc_title => document.get('proxies.dcTitle'),

          :edm_country => document.get('europeanaAggregation.edmCountry'),
          :edm_dataset_name => document.get('edmDatasetName'),
          :edm_is_shown_at => document.get('aggregations.edmIsShownAt'),
          :edm_is_shown_by => document.get('aggregations.edmIsShownBy'),
          :edm_language => document.get('europeanaAggregation.edmLanguage'),
          :edm_preview => document.get('europeanaAggregation.edmPreview'),
          :edm_provider => document.get('aggregations.edmProvider'),
          :edm_rights =>  document.get('aggregations.edmRights'),

          :latitude => document.get('places.latitude'),
          :longitude => document.get('places.longitude'),

          :title => document.get('title'),
          :type => document.get('type'),

          :year => document.get('year')
        }
      end

      # All
      def doc
        document.as_json.to_s 
      end
    end
  end
end
