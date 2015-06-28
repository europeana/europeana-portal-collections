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
          footer: common_footer,
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
        {
          object: {
            concepts: concept_data,
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

            people: people_data,
            places: place_data,
            provenance: provenance_data,
            properties: property_data,
            
            # note: view is currently showing the rights attached to the first media-item and not this value
            rights: simple_rights_label_data(render_document_show_field_value(document, 'aggregations.edmRights')),
            title: render_document_show_field_value(document, 'proxies.dcTitle'),
            type: render_document_show_field_value(document, 'proxies.dcType')

          },
          
          refs_rels: ref_rel_data,
            
          similar: {
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
          },
          times: time_data,
          timestamps: {
            created: "2014-05-27T20:14:08.870Z",
            updated: "2014-09-07T15:50:25.953Z"
          }
        }
      end

      def labels
        {
          show_more_meta: t('site.object.actions.show-more-data'),
          show_less_meta: t('site.object.actions.show-less-data'),
          rights: t('site.object.meta-label.rights')
        }
      end

      #def data
      #  {
      #    edm_is_shown_by: render_document_show_field_value(document, 'aggregations.edmIsShownBy'),
      #  }
      #end

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

      def people_data
        
        dc_creator     = render_document_show_field_value(document, 'proxies.dcCreator')
        dc_contributor = render_document_show_field_value(document, 'proxies.dcContributor')
        
        dc_creator_begin = render_document_show_field_value(document, 'agents.begin') 
        dc_creator_end   = render_document_show_field_value(document, 'agents.end')
        
        {
          content_present: (!dc_creator.nil? || !dc_contributor.nil?),
          title: t('site.object.meta-label.people'),
          creator: {
            title: t('site.object.meta-label.creator'),
            name:  merge_values(['proxies.dcCreator', 'agents.prefLabel'], ', '),
            url:   dc_creator ? search_path(q: "\"#{dc_creator}\"") : nil,
            life: {
                content_present: (!dc_creator_begin.nil? || !dc_creator_end.nil?),
                from: {
                    long:  dc_creator_begin,
                    short: dc_creator_begin
                },
                to: {
                    long:  dc_creator_end,
                    short: dc_creator_end
                }
            },
            biography: {
                text:        nil,
                source:     nil,
                source_url: nil
            }
          },
          contributor: {
            title: t('site.object.meta-label.contributor'),            
            name: dc_contributor,
            url:  dc_contributor ? search_path(q: "\"#{dc_contributor}\"") : nil,
          } 
          
        }
      end
      
      def place_data
        spatial  = collect_values(['proxies.dctermsSpatial'])
        coverage = collect_values(['proxies.dcCoverage'])
        places   = [].push(*spatial).push(*coverage)
          
        {
          content_present: places.size > 0,
          spatial: {
            content_present: spatial.size > 0,
            label:  t('site.object.meta-label.location'),
            items: spatial.collect do |space|
              {
                text: space
              }
            end            
          },
          coverage: {
            content_present: coverage.size > 0,
            label:  t('site.object.meta-label.place-time'),
            items: coverage.collect do |space|
              {
                text: space
              }
            end            
          }
        }        
      end
      
      def time_data
        issued   = collect_values(['proxies.dctermsIssued'])
        temporal = collect_values(['proxies.dctermsTemporal'])
        times    = [].push(*issued).push(*temporal)
          
        {
          content_present: times.size > 0,
          issued: {
            content_present: issued.size > 0,
            label: t('site.object.meta-label.issued'),
            items: issued.collect do |item|
              {
                text: item
              }
            end            
          },
          temporal: {
            content_present: temporal.size > 0,
            label: t('site.object.meta-label.temporal'),
            items: temporal.collect do |item|
              {
                text: item
              }
            end            
          }
        }        
      end
      
      def ref_rel_data
        relations  = collect_values(['proxies.dcRelation'])
        references = collect_values(['proxies.dctermsReferences'])
        ref_rels   = [].push(*relations).push(*references)
          
        {
          content_present: ref_rels.size > 0,
          relations: {
            content_present: relations.size > 0,
            label:  t('site.object.meta-label.relations'),
            items: relations.collect do |rel|
              {
                text: rel
              }
            end            
          },
          references: {
            content_present: references.size > 0,
            label:  t('site.object.meta-label.references'),
            items: references.collect do |ref|
              {
                text: ref
              }
            end            
          }
        }        
      end

      def concept_data

        concept_types    = []
        concepts_other   = []
        concept_subjects = []

        document.proxies.each{|proxy|
          val = proxy.fetch('dcType', nil)
          val.each{|type|
            concept_types <<  type.downcase 
          } unless val.blank?
        }

        if (collect_values(['concepts.prefLabel']).size > 0)
          document.concepts.each{|concept|
            val = concept.fetch('prefLabel', nil)
            val.each{|prefLabel|
              (concepts_other <<  prefLabel.downcase) unless concept_types.index(prefLabel.downcase)
            } unless  val.blank?
          }
        end

        if(collect_values(['aggregations.edmUgc']).size > 0)
          concepts_other << t('site.object.meta-label.ugc')
        end
        
        document.proxies.each{|proxy|
          val = proxy.fetch('dcSubject', nil)
          val.each{|subject|
            (concept_subjects << subject.downcase) unless  concept_types.index(subject.downcase)
          } unless val.blank?
        }
        
        concept_types    = concept_types.uniq
        concepts_other   = concepts_other.uniq
        concept_subjects = concept_subjects.uniq
        
        {
          type_items: (concept_types.size == 0) ? {} :
            {
              label:  t('site.object.meta-label.type'),
              items: concept_types.collect do |concept|
                {
                  text:   concept,
                  url:    search_path(q: "what:\"#{concept}\""),
                }
              end
            },
            
          concept_items:  (concepts_other.size == 0) ? {} :{
            label:  t('site.object.meta-label.concept'),
            items: concepts_other.collect do |concept|
              {
                text:   concept,
                url:    concept == t('site.object.meta-label.ugc') ? root_url + ("search?f[UGC][]=true") : search_path(q: "what:\"#{concept}\""),
              }
            end          
          },
          
          concept_subjects:  (concept_subjects.size == 0) ? {} :{
            label:  t('site.object.meta-label.subject'),
            items: concept_subjects.collect do |concept|
              {
                text:   concept,
                url:    search_path(q: "what:\"#{concept}\""),
              }
            end          
          }
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

        require 'time'

        origins_publisher     = collect_values(['proxies.dcPublisher'])
        origins_provider      = collect_values(['aggregations.edmProvider'])
        origins_provenance    = collect_values(['proxies.dctermsProvenance'])
        origins_data_provider = collect_values(['aggregations.edmDataProvider'])
        origins_country       = collect_values(['europeanaAggregation.edmCountry'])
        origins_identifier    = collect_values(['proxies.dcIdentifier'])
        originsOther          = collect_values(['proxies.dcSource', 'proxies.dctermsReferences', 'proxies.dcIdentifier'])
        origins_t_created     = collect_values(['timestamp_created'])
        origins_t_updated     = collect_values(['timestamp_created'])
        origins_t             = []
        
        strf = "%Y-%m-%d";
        
        if(origins_t_created.size > 0)
          date = Time.parse(origins_t_created[0]) rescue nil
          if(!date.nil?)
            origins_t.push(t('site.object.meta-label.timestamp_created', timestamp_created: date.strftime(strf) ))
          end
        end
        if(origins_t_updated.size > 0)
          date = Time.parse(origins_t_updated[0]) rescue nil
          if(!date.nil?)
            origins_t.push(t('site.object.meta-label.timestamp_updated', timestamp_updated: date.strftime(strf) ))
          end
        end
        
        origins = []
        origins.push(*origins_identifier).push(*origins_provenance).push(*origins_t).push(*origins_publisher)
        origins.push(*origins_provider).push(*origins_data_provider).push(*origins_country)
        origins.push(*originsOther)

        {
          content_present: origins.size > 0,
          items: origins.uniq.collect do |origin|
            {
              label: origins_publisher.index(origin)     == 0 ? t('site.object.meta-label.publisher') + ':' : 
                     origins_provider.index(origin)      == 0 ? t('site.object.meta-label.provider') + ':' : 
                     origins_provenance.index(origin)    == 0 ? t('site.object.meta-label.provenance') + ':' : 
                     origins_data_provider.index(origin) == 0 ? t('site.object.meta-label.data-provider') + ':' :
                     origins_identifier.index(origin)    == 0 ? t('site.object.meta-label.identifier') + ':' :
                     origins_country.index(origin)       == 0 ? t('site.object.meta-label.providing-country') + ':' : false,
              text: origin,
              url:  origins_data_provider.index(origin) ? render_document_show_field_value(document, 'aggregations.edmIsShownAt') : false
            }
          end
        }
      end
      
      def property_data
        
        properties_cs  = collect_values(['proxies.dcMedium', 'proxies.dcDuration'])
        properties_fmt = collect_values(['aggregations.webResources.dcFormat'])
        properties_xt  = collect_values(['proxies.dctermsExtent'])
        properties_lng = collect_values(['proxies.dcLanguage'])
                    
        props = [].push(*properties_fmt).push(*properties_cs).push(*properties_xt).push(*properties_lng)
 
        if(props.empty?)
          return 
        end
        
        {
          content_present: props.size > 0,
          items: props.collect do |property|
            {
              label:  properties_fmt.index(property) == 0 ? t('site.object.meta-label.format') + ':' : 
                      properties_xt.index(property) == 0 ? t('site.object.meta-label.extent') + ':' :
                      properties_lng.index(property) == 0 ? t('site.object.meta-label.language') + ':' : false,
              text:  property,
              url:   properties_cs.index(property)       ? search_path(q: "what:\"#{property}\"") : false
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
