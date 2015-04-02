
module Templates
  module Search
    class SearchObject < ApplicationView

      def debug
        JSON.pretty_generate(document.as_json)
      end

      def navigation
        query_params = current_search_session.try(:query_params) || {}

        if search_session['counter']
          per_page = (search_session['per_page'] || default_per_page).to_i
          counter = search_session['counter'].to_i

          query_params[:per_page] = per_page unless search_session['per_page'].to_i == default_per_page
          query_params[:page] = ((counter - 1)/ per_page) + 1
        end

        back_link_url = if query_params.empty?
          search_action_path(only_path: true)
        else
          self.url_for(query_params)
        end

        # old arrows '❬ ' + ' ❭'
        navigation = {
          next_prev: {
            prev_text: 'previous result',
            back_url: back_link_url,
            back_text: 'return to search results',
            next_text: 'next document'
          }
        }
        if @previous_document
          navigation[:next_prev].merge!({
            prev_url: url_for_document(@previous_document),
            prev_link_attrs: [
              {
                name: 'data-context-href',
                value: track_document_path(@previous_document, session_tracking_path_opts(search_session['counter'].to_i - 1))
              }
            ],
          })
        end
        if @next_document
          navigation[:next_prev].merge!({
            next_url: url_for_document(@next_document),
            next_link_attrs: [
              {
                name: 'data-context-href',
                value: track_document_path(@next_document, session_tracking_path_opts(search_session['counter'].to_i + 1))
              }
            ],
          })
        end

        navigation
      end

      def links
        res = {
          :download  => document.get('europeanaAggregation.edmPreview'),
          :original_context => document.get('aggregations.edmIsShownAt')
        }
      end

      def labels
        {
          :show_more_meta => "show more object data",
          :download => "download",
          :rights => "rights:",
          :description => "description:",
          :dc_type => "type:",
          :agent => get_agent_label,
          :creator => "Creator",
          :mlt => "similar items"
        }
      end

      def data
        {
          :agent_pref_label => document.get('agents.prefLabel'),
          :agent_begin  => document.get('agents.begin'),
          :agent_end  => document.get('agents.end'),

          :concepts => get_doc_concepts,

          :dc_description => get_doc_description,
          :dc_type => document.get('proxies.dcType'),
          :dc_creator => document.get('proxies.dcCreator'),

          :dc_format => document.get('proxies.dcFormat'),
          :dc_identifier => document.get('proxies.dcIdentifier'),

          :dc_terms_created => document.get('proxies.dctermsCreated'),
          :dc_terms_created_web => document.get('aggregations.webResources.dctermsCreated'),

          :dc_terms_extent => document.get('proxies.dctermsExtent'),
          :dc_title => document.get('proxies.dcTitle'),
          :dc_type => document.get('proxies.dcType'),

          :edm_country => document.get('europeanaAggregation.edmCountry'),
          :edm_dataset_name => document.get('edmDatasetName'),
          :edm_is_shown_at => document.get('aggregations.edmIsShownAt'),
          :edm_is_shown_by => document.get('aggregations.edmIsShownBy'),
          :edm_language => document.get('europeanaAggregation.edmLanguage'),
          :edm_preview => document.get('europeanaAggregation.edmPreview'),
          :edm_provider => document.get('aggregations.edmProvider'),
          :edm_data_provider => document.get('aggregations.edmDataProvider'),
          :edm_rights =>  document.get('aggregations.edmRights'),

          :latitude => document.get('places.latitude'),
          :longitude => document.get('places.longitude'),

          :title => get_doc_title,
          :title_extra => get_doc_title_extra,
          :type => document.get('type'),

          :year => document.get('year')
        }
      end


      private

      def session_tracking_path_opts(counter)
        {
          per_page: params.fetch(:per_page, search_session['per_page']),
          counter: counter,
          search_id: current_search_session.try(:id)
        }
      end

      def get_doc_title

        # force array return with empty default

        title = document.get('title', :default=>'')
        title = title.size == 0 ? document.get('proxies.dcTitle') : title[0]
        title
      end

      def get_doc_title_extra

        # force array return with empty default

        title = document.get('title', :default=>'')
        if title.size > 1
          title.shift
          title
        else
          nil
        end
      end

      def get_doc_description

        # This line returns what looks like a Ruby hash for some records, see here:
        #
        # http://localhost:3000/record/2048217/MUDE_M_0656_01.html

        desc = document.get('proxies.dcDescription')
        desc.size > 0 ? desc : nil
      end

      def get_agent_label
        label = document.get('agents.rdaGr2ProfessionOrOccupation')
        label ||= 'creator'
        label
      end


      def get_doc_concepts
        concepts = document.get('concepts.prefLabel', :default => '')
        concepts.size > 0 ? concepts.flatten : nil
      end

    end
  end
end
