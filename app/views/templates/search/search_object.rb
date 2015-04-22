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
          url_for(query_params)
        end

        # old arrows '❬ ' + ' ❭'
        navigation = {
          next_prev: {
            prev_text: t('site.object.nav.prev'),
            back_url:  back_link_url,
            back_text: t('site.object.nav.return-to-search'),
            next_text: t('site.object.nav.next')
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

      def content
        
        {
          :object => {
            :creator => {
              :name => render_document_show_field_value(document, 'proxies.dcCreator'),
              :life  => {
                  :from  => {
                      :long  => render_document_show_field_value(document, 'agents.begin'),
                      :short => render_document_show_field_value(document, 'agents.end')
                  },
                  :to => {
                      :long   => render_document_show_field_value(document, 'agents.end'),
                      :short  => render_document_show_field_value(document, 'agents.end')
                  }
              },
              :title => (render_document_show_field_value(document, 'agents.rdaGr2ProfessionOrOccupation') || t('site.object.meta-label.creator')) + ':',
              :biography => {
                  :text =>        nil,
                  :source  =>     nil,
                  :source_url  => nil
              }
            },
            
            :creation_date => render_document_show_field_value(document, 'proxies.dctermsCreated'),
            :description => render_document_show_field_value(document, 'proxies.dcDescription'),
            
            :download  => content_object_download,

            :geo => {
              :latitude => render_document_show_field_value(document, 'places.latitude'),
              :longitude => render_document_show_field_value(document, 'places.longitude'),
              :long_and_lat => has_long_and_lat,
              :placeName => render_document_show_field_value(document, 'places.prefLabel'),
              :labels => {
                
                :longitude      => t('site.object.meta-label.longitude') + ':',
                :latitude       => t('site.object.meta-label.latitude') + ':',
                :map            => t('site.object.meta-label.map') + ':',   
                :points         => {
                    :n          => t('site.object.points.north'),
                    :s          => t('site.object.points.south'),
                    :e          => t('site.object.points.east'),
                    :w          => t('site.object.points.west')
                }

              }
            },
            
            :images => {
              :thumbnail => render_document_show_field_value(document, 'europeanaAggregation.edmPreview', tag: false)
            },
              
            :origin => {
              :url => render_document_show_field_value(document, 'aggregations.edmIsShownAt'),
              :institution_name => render_document_show_field_value(document, 'aggregations.edmDataProvider')
            },
            :rights  => {
              :license_public  => false,
              :license_human   => render_document_show_field_value(document, 'aggregations.edmRights')
            },
            :title => render_document_show_field_value(document, 'proxies.dcTitle'),
            :type => render_document_show_field_value(document, 'proxies.dcType')

          },
          :related => {
            :title => t('site.object.similar-items') + ':',
            :items => [
              {:title => 'one'},
              {:title => 'two'},
              {:title => 'three'},
              {:title => 'four'}
            ]
          }
        }  
      end

      def labels
        {
          show_more_meta: t('site.object.actions.show-more-data'),
          show_less_meta: t('site.object.actions.show-less-data'),
          download:       t('site.object.actions.downloaddata'),
          
          :agent          => t('site.object.meta-label.creator') + ':',
          :creator        => t('site.object.meta-label.creator') + ':',
          :dc_type        => t('site.object.meta-label.type') + ':',
          :description    => t('site.object.meta-label.description') + ':',
          
          #:longitude      => t('site.object.meta-label.longitude') + ':',
          #:latitude       => t('site.object.meta-label.latitude') + ':',
          #:map            => t('site.object.meta-label.map') + ':',
          
          #:mlt            => t('site.object.similar-items') + ':',
          :rights         => t('site.object.meta-label.rights')
        }
      end

      def data
        {
          agent_pref_label: render_document_show_field_value(document, 'agents.prefLabel'),
          agent_begin: render_document_show_field_value(document, 'agents.begin'),
          agent_end: render_document_show_field_value(document, 'agents.end'),

          concepts: render_document_show_field_value(document, 'concepts.prefLabel'),

          dc_description: render_document_show_field_value(document, 'proxies.dcDescription'),
          dc_type: render_document_show_field_value(document, 'proxies.dcType'),
          dc_creator: render_document_show_field_value(document, 'proxies.dcCreator'),

          dc_format: render_document_show_field_value(document, 'proxies.dcFormat'),
          dc_identifier: render_document_show_field_value(document, 'proxies.dcIdentifier'),

          dc_terms_created: render_document_show_field_value(document, 'proxies.dctermsCreated'),
          dc_terms_created_web: render_document_show_field_value(document, 'aggregations.webResources.dctermsCreated'),

          dc_terms_extent: render_document_show_field_value(document, 'proxies.dctermsExtent'),
          dc_title: render_document_show_field_value(document, 'proxies.dcTitle'),
          dc_type: render_document_show_field_value(document, 'proxies.dcType'),

          edm_country: render_document_show_field_value(document, 'europeanaAggregation.edmCountry'),
          edm_dataset_name: render_document_show_field_value(document, 'edmDatasetName'),
          edm_is_shown_at: render_document_show_field_value(document, 'aggregations.edmIsShownAt'),
          edm_is_shown_by: render_document_show_field_value(document, 'aggregations.edmIsShownBy'),
          edm_language: render_document_show_field_value(document, 'europeanaAggregation.edmLanguage'),
          edm_preview: render_document_show_field_value(document, 'europeanaAggregation.edmPreview'),
          edm_provider: render_document_show_field_value(document, 'aggregations.edmProvider'),
          edm_data_provider: render_document_show_field_value(document, 'aggregations.edmDataProvider'),
          edm_rights:  render_document_show_field_value(document, 'aggregations.edmRights'),

          title: doc_title,
          title_extra: doc_title_extra,
          type: render_document_show_field_value(document, 'type'),
          
          #:latitude => render_document_show_field_value(document, 'places.latitude'),
          #:longitude => render_document_show_field_value(document, 'places.longitude'),
          #:long_and_lat => has_long_and_lat,
          #:placeName => render_document_show_field_value(document, 'places.prefLabel'),
          
          year: render_document_show_field_value(document, 'year')
        }
      end

      private

      def content_object_download
        links = []

        if edm_is_shown_by_download_url.present?
          links << {
            text: t('site.object.actions.download'),
            url: edm_is_shown_by_download_url
          }
        end

        if false # add more links on useful conditions
          links << {
            text: 'Epub',
            url: 'http://www.europeana.eu/'
          }
        end

        return nil unless links.present?

        {
          primary: links.first,
          secondary: {
            items: (links.size == 1) ? nil : links[1..-1]
          }
        }
      end

      def edm_is_shown_by_download_url
        @edm_is_shown_by_download_url ||= begin
          if ENV['EDM_IS_SHOWN_BY_PROXY'] && document.fetch('aggregations.edmIsShownBy', false)
            ENV['EDM_IS_SHOWN_BY_PROXY'] + document.fetch('about')
          else
            render_document_show_field_value(document, 'aggregations.edmIsShownBy')
          end
        end
      end

      def has_long_and_lat
        latitude = render_document_show_field_value(document, 'places.latitude')
        longitude = render_document_show_field_value(document, 'places.longitude')
        !latitude.nil? && latitude.size > 0 && !longitude.nil? && longitude.size > 0
      end

      def session_tracking_path_opts(counter)
        {
          per_page: params.fetch(:per_page, search_session['per_page']),
          counter: counter,
          search_id: current_search_session.try(:id)
        }
      end

      def doc_title
        # force array return with empty default
        title = document.fetch(:title, nil)

        if title.blank?
          render_document_show_field_value(document, 'proxies.dcTitle')
        else
          title.first
        end
      end

      def doc_title_extra
        # force array return with empty default
        title = document.fetch(:title, [])

        if title.size > 1
          title[1..-1]
        else
          nil
        end
      end
    end
  end
end
