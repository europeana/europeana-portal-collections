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
          global: navigation_global,
          next_prev: {
            prev_text: t('site.object.nav.prev'),
            back_url:  back_link_url,
            back_text: t('site.object.nav.return-to-search'),
            next_text: t('site.object.nav.next')
          }
        }
        if @previous_document
          navigation[:next_prev].merge!({
            prev_url: document_path(@previous_document, format: 'html'),
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
            next_url: document_path(@next_document, format: 'html'),
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
        
        dcCreator = render_document_show_field_value(document, 'proxies.dcCreator')
        
        {
          object: {
            concepts: concept_data,
            creator: {
              name:     merge_values(['proxies.dcCreator', 'proxies.dcContributor', 'agents.prefLabel'], ', '),
              name_url: dcCreator ? search_path(q: "\"#{dcCreator}\"") : nil,
              life: {
                  from: {
                      long: render_document_show_field_value(document, 'agents.begin'),
                      short: render_document_show_field_value(document, 'agents.end')
                  },
                  to: {
                      long: render_document_show_field_value(document, 'agents.end'),
                      short: render_document_show_field_value(document, 'agents.end')
                  }
              },
              #title: (render_document_show_field_value(document, 'agents.rdaGr2ProfessionOrOccupation') || t('site.object.meta-label.creator')) + ':',
              title: t('site.object.meta-label.creator'),
              biography: {
                  text:        nil,
                  source:     nil,
                  source_url: nil
              }
            },

            creation_date: render_document_show_field_value(document, 'proxies.dctermsCreated'),
            dates: date_data,
            description: render_document_show_field_value(document, 'proxies.dcDescription'),
            download: content_object_download,
            media: media_items,

            meta_additional: {
              geo: {
                latitude:  '"' + (render_document_show_field_value(document, 'places.latitude')  || '' ) + '"',
                longitude: '"' + (render_document_show_field_value(document, 'places.longitude') || '' ) + '"',
                long_and_lat: has_long_and_lat,
                placeName: render_document_show_field_value(document, 'places.prefLabel'),
                labels: {
  
                  longitude: t('site.object.meta-label.longitude') + ':',
                  latitude: t('site.object.meta-label.latitude') + ':',
                  map: t('site.object.meta-label.map'),
                  points: {
                      n: t('site.object.points.north'),
                      s: t('site.object.points.south'),
                      e: t('site.object.points.east'),
                      w: t('site.object.points.west')
                  }
  
                }
              }
            },

            origin: {
              url:                 render_document_show_field_value(document, 'aggregations.edmIsShownAt'),
              institution_name:    render_document_show_field_value(document, 'aggregations.edmDataProvider'),
              institution_country: render_document_show_field_value(document, 'europeanaAggregation.edmCountry'),
              content_present:     collect_values(['aggregations.edmDataProvider', 'europeanaAggregation.edmCountry']).length > 0
            },

            provenance: provenance_data,
            properties: property_data,
            
            # note: view is currently showing the rights attached to the first media-item and not this value
            rights: simple_rights_label_data(render_document_show_field_value(document, 'aggregations.edmRights')),
            title: render_document_show_field_value(document, 'proxies.dcTitle'),
            type: render_document_show_field_value(document, 'proxies.dcType')

          },
            
          related: {
            title: t('site.object.similar-items') + ':',
            more_items_query: search_path(mlt: document.id),
            items: @similar.map { |doc|
              {
                url: document_path(doc, format: 'html'),
                title: render_document_show_field_value(doc, ['dcTitleLangAware', 'title']),
                img: {
                  alt: render_document_show_field_value(doc, ['dcTitleLangAware', 'title']),
                  src: render_document_show_field_value(doc, 'edmPreview')
                }
              }
            }
          }
        }
      end

      def labels
        {
          show_more_meta: t('site.object.actions.show-more-data'),
          show_less_meta: t('site.object.actions.show-less-data'),
          #download:       t('site.object.actions.downloaddata'),

          #agent:       t('site.object.meta-label.creator') + ':',
          #creator:     t('site.object.meta-label.creator') + ':',
          #dc_type:     t('site.object.meta-label.type') + ':',
          #description: t('site.object.meta-label.description') + ':',

          rights: t('site.object.meta-label.rights')
        }
      end

      def data
        {
          #agent_pref_label: render_document_show_field_value(document, 'agents.prefLabel'),
          #agent_begin: render_document_show_field_value(document, 'agents.begin'),
          #agent_end: render_document_show_field_value(document, 'agents.end'),

          #concepts: render_document_show_field_value(document, 'concepts.prefLabel'),

          #dc_description: render_document_show_field_value(document, 'proxies.dcDescription'),
          #dc_creator: render_document_show_field_value(document, 'proxies.dcCreator'),

          #dc_format: render_document_show_field_value(document, 'proxies.dcFormat'),
          #dc_identifier: render_document_show_field_value(document, 'proxies.dcIdentifier'),

          #dc_terms_created: render_document_show_field_value(document, 'proxies.dctermsCreated'),
          #dc_terms_created_web: render_document_show_field_value(document, 'aggregations.webResources.dctermsCreated'),

          #dc_terms_extent: render_document_show_field_value(document, 'proxies.dctermsExtent'),
          #dc_title: render_document_show_field_value(document, 'proxies.dcTitle'),
          #dc_type: render_document_show_field_value(document, 'proxies.dcType'),

          #edm_country: render_document_show_field_value(document, 'europeanaAggregation.edmCountry'),
          #edm_dataset_name: render_document_show_field_value(document, 'edmDatasetName'),
          #edm_is_shown_at: render_document_show_field_value(document, 'aggregations.edmIsShownAt'),
          edm_is_shown_by: render_document_show_field_value(document, 'aggregations.edmIsShownBy'),
          #edm_language: render_document_show_field_value(document, 'europeanaAggregation.edmLanguage'),
          #edm_preview: render_document_show_field_value(document, 'europeanaAggregation.edmPreview'),
          #edm_provider: render_document_show_field_value(document, 'aggregations.edmProvider'),
          #edm_data_provider: render_document_show_field_value(document, 'aggregations.edmDataProvider'),
          #edm_rights:  render_document_show_field_value(document, 'aggregations.edmRights'),

          #title: doc_title,
          #title_extra: doc_title_extra,
          #type: render_document_show_field_value(document, 'type'),

          #year: render_document_show_field_value(document, 'year')
        }
      end

      private

      def collect_values(fields, doc = document)
        values = []
        fields.each { |field| 
          value = render_document_show_field_value(doc, field)
          values << value unless value.nil?
        }
        values.uniq
      end
      
      
      def merge_values(fields, separator = ' ')
        collect_values(fields).join(separator)
      end
      
      
      def concept_data
        
        conceptsType  = collect_values(['proxies.dcType'])
        conceptsOther = collect_values(['concepts.prefLabel', 'proxies.dcSubject'])
        concepts      = [].push(*conceptsType).push(*conceptsOther)
                
        if(concepts.empty?)
          return 
        end
        
        {
          content_present: concepts.size > 0,
          items: concepts.collect do |concept|
            {
              text: concept,
              url:  search_path(q: "what:\"#{concept}\""),
              label:  conceptsType.index(concept)  == 0 ? t('site.object.meta-label.type') + ':' : 
                      conceptsOther.index(concept) == 0 ? t('site.object.meta-label.concept') + ':' : false
            }
          end          
        }        
      end

      
      def date_data
        datesPL = collect_values([
          'timespans.prefLabel'
        ])
        datesCS = collect_values(['proxies.dctermsIssued', 'proxies.dctermsCreated', 'proxies.dctermsPublished', 'proxies.dcDate'])
        dates   = [].push(*datesPL).push(*datesCS).uniq
        {
          content_present: dates.size > 0,
          items: dates.collect do |date|
            {
              label:  datesPL.index(date) == 0 ? t('site.object.meta-label.period') + ':' : 
                      datesCS.index(date) == 0 ? t('site.object.meta-label.creation-date') + ':' : false,
              text: date,
              url:  datesCS.index(date) ? search_path(q: "when:\"#{date}\"") : false
            }
          end
        }
      end

      
      def provenance_data
        # origin

        originsPublisher     = collect_values(['proxies.dcPublisher'])
        originsProvider      = collect_values(['aggregations.edmProvider'])
        originsDataProvider  = collect_values(['aggregations.edmDataProvider'])
        originsCountry       = collect_values(['europeanaAggregation.edmCountry'])
        originsOther         = collect_values(['proxies.dctermsProvenance', 'proxies.dcSource', 'proxies.dctermsReferences', 'proxies.dcIdentifier'])
          
        origins = [].push(*originsPublisher).push(*originsProvider).push(*originsDataProvider).push(*originsCountry).push(*originsOther)
        {
          content_present: origins.size > 0,
          items: origins.uniq.collect do |origin|
            {
              label: originsPublisher.index(origin)    == 0 ? t('site.object.meta-label.publisher') + ':' : 
                     originsProvider.index(origin)     == 0 ? t('site.object.meta-label.provider') + ':' : 
                     originsDataProvider.index(origin) == 0 ? t('site.object.meta-label.data-provider') + ':' :
                     originsCountry.index(origin)      == 0 ? t('site.object.meta-label.providing-country') + ':' : false,
              text: origin,
              url:  originsDataProvider.index(origin) ? render_document_show_field_value(document, 'aggregations.edmIsShownAt') : false
            }
          end
        }
      end
      
      def property_data
        
        properties    = collect_values(['proxies.dctermsExtent'])
        propertiesCS  = collect_values(['proxies.dcMedium', 'proxies.dcDuration'])
        propertiesFmt = collect_values(['aggregations.webResources.dcFormat'])
          
        props = [].push(*propertiesFmt).push(*properties).push(*propertiesCS)
 
        if(props.empty?)
          return 
        end
        
        {
          content_present: props.size > 0,
          items: props.collect do |property|
            {
              text:  property,
              url:   propertiesCS.index(property)       ? search_path(q: "what:\"#{property}\"") : false,
              label: propertiesFmt.index(property) == 0 ? t('site.object.meta-label.format') + ':' : false
            }
          end
        }
      end
      
      
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
          if ENV['EDM_IS_SHOWN_BY_PROXY'] && document.aggregations.first.fetch('edmIsShownBy', false)
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

      
      # Media
      
      def media_type(url)
        ext = url[/\.[^.]*$/].downcase
        if(!['.avi', '.mp3'].index(ext).nil?)
          'audio'
        elsif(!['.jpg', '.jpeg'].index(ext).nil?)
          'image'
        elsif(!['.mp4', '.ogg'].index(ext).nil?)
          'video'
        elsif(!['.txt', '.pdf'].index(ext).nil?)
          'text'
        else
          'unknown'
        end
      end
      
      def simple_rights_label_data(rights)
        
        # global.facet.reusability.permission      Only with permission
        # global.facet.reusability.open            Yes with attribution
        # global.facet.reusability.restricted      Yes with restrictions

        prefix = t('global.facet.header.reusability') + ' '
        
        if(rights.index('http://creativecommons.org/licenses/by-nc-nd') == 0)
          {
            license_public: false,
            license_human:  prefix + t('global.facet.reusability.restricted')
          }
        elsif(rights.index('http://creativecommons.org/licenses/by-nc-sa') == 0)
          {
            license_public: true,
            license_human:  prefix + t('global.facet.reusability.open')
          }
        elsif(rights.index('http://www.europeana.eu/rights/rr-f') == 0)
          {
            license_public: false,
            license_human:  prefix + t('global.facet.reusability.permission')
          }
        elsif(rights.index('http://creativecommons.org/publicdomain/mark') == 0)
          {
            license_public: true,
            license_human:  prefix + t('global.facet.reusability.open')
          }
        else
          {
            license_public: true,
            license_human:  'todo: map this rights value(' + rights + ')'
          }
        end
            
      end
      
      def media_items
        
        aggregation = document.aggregations.first
        return [] unless aggregation.respond_to?(:webResources)
        
        # main item
            
        media_type  = render_document_show_field_value(document, 'type').downcase          
        edm_preview = render_document_show_field_value(document, 'europeanaAggregation.edmPreview', tag: false)
        
        primary_media = {
          preview:    edm_preview,
          thumbnail:  edm_preview,
          file:       edm_preview,
          media_type: media_type,
          rights:     simple_rights_label_data(render_document_show_field_value(document, 'aggregations.edmRights'))
          #  json: document.as_json
        }
        
        if(media_type == 'image')
          primary_media['is_image']  = true
        elsif(media_type == 'audio')
          primary_media['is_audio']  = true
        elsif(media_type == 'text')
          primary_media['is_text']  = true
        elsif(media_type == 'video')
          primary_media['is_video']  = true
        else
          primary_media['is_unkown_type']  = media_type
        end

        # additional items
          
        additional_items = aggregation.webResources.collect do |web_resource|
          
          preview_url  = render_document_show_field_value(web_resource, 'about')
          preview_type = media_type(preview_url)
          
          item = {
            alt:  preview_type + ' - ' + preview_url,
            file: preview_url,
            rights: {
              license_public: true,
              license_human:  render_document_show_field_value(web_resource, 'webResourceDcRights'),
            },
            media_type: preview_type
            #  json: web_resource.as_json
          }
          
          if(preview_type == 'image')
            item['thumbnail'] = preview_url
          elsif(preview_type == 'audio')
            item['thumbnail'] = 'http://europeanastatic.eu/api/image?size=BRIEF_DOC&type=SOUND'
          elsif(preview_type == 'text')
            item['thumbnail'] = 'http://europeanastatic.eu/api/image?size=BRIEF_DOC&type=TEXT'
          elsif(preview_type == 'video')
            item['thumbnail'] = 'http://europeanastatic.eu/api/image?size=BRIEF_DOC&type=VIDEO'
          else
            # unknown value mapped to thumbnail in view.
            #  - needed to see hi-res of this record:
            #    - http://localhost:3000/record/90402/SK_A_2344.html
            item['thumbnail'] = preview_url
          end
          
          item
        end

        {
          primary: primary_media,
            additional: {
              items: additional_items
            }
        }
          
      end
    end
  end
end
