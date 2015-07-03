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
          query_params[:page] = ((counter - 1) / per_page) + 1
        end

        back_link_url = if query_params.empty?
                          search_action_path(only_path: true)
                        else
                          url_for(query_params)
                        end

        navigation = {
          global: navigation_global,
          footer: common_footer,
          next_prev: {
            prev_text: t('site.object.nav.prev'),
            back_url: back_link_url,
            back_text: t('site.object.nav.return-to-search'),
            next_text: t('site.object.nav.next')
          }
        }
        if @previous_document
          navigation[:next_prev].merge!(
            prev_url: document_path(@previous_document, format: 'html'),
            prev_link_attrs: [
              {
                name: 'data-context-href',
                value: track_document_path(@previous_document, session_tracking_path_opts(search_session['counter'].to_i - 1))
              }
            ]
          )
        end
        if @next_document
          navigation[:next_prev].merge!(
            next_url: document_path(@next_document, format: 'html'),
            next_link_attrs: [
              {
                name: 'data-context-href',
                value: track_document_path(@next_document, session_tracking_path_opts(search_session['counter'].to_i + 1))
              }
            ]
          )
        end
        navigation
      end

      def content
        {
          object: {
            concepts: data_section(
              title: 'site.object.meta-label.concepts',
              sections: [
                {
                  title: 'site.object.meta-label.type',
                  fields: ['dcType'],
                  collected: document.proxies.map do |proxy|
                    proxy.fetch('dcType', nil)
                  end.flatten.compact,
                  url: 'what'
                },
                {
                  title: 'site.object.meta-label.concept',
                  url: 'what',
                  fields: ['aggregations.edmUgc'],
                  collected: collect_values(['concepts.prefLabel']).size == 0 ? [] : document.concepts.map do |concept|
                    concept.fetch('prefLabel', nil).compact.join('')
                  end,
                  override_val: 'true',
                  overrides: [
                    {
                      field_title: t('site.object.meta-label.ugc'),
                      field_url: root_url + ('search?f[UGC][]=true')
                    }
                  ]
                },
                {
                  title: 'site.object.meta-label.subject',
                  url: 'what',
                  fields: [],
                  collected: document.proxies.map do |proxy|
                    proxy.fetch('dcSubject', nil)
                  end.flatten.compact
                }
              ]
            ),
            creation_date: render_document_show_field_value(document, 'proxies.dctermsCreated'),
            dates: data_section(
              title: 'site.object.meta-label.time',
              sections: [
                {
                  title: 'site.object.meta-label.date',
                  fields: ['proxies.dcDate']
                },
                {
                  title: 'site.object.meta-label.period',
                  fields: ['timespans.prefLabel']
                },
                {
                  title: 'site.object.meta-label.publication-date',
                  fields: ['proxies.dctermsPublished']
                },
                {
                  title: 'site.object.meta-label.issued',
                  fields: ['proxies.dctermsIssued']
                },
                {
                  title: 'site.object.meta-label.temporal',
                  fields: ['proxies.dctermsTemporal']
                },
                {
                  title: 'site.object.meta-label.place-time',
                  fields: ['proxies.dcCoverage']
                },
                {
                  title: 'site.object.meta-label.creation-date',
                  fields: ['proxies.dctermsIssued'],
                  collected: document.proxies.map do |proxy|
                    termsCreated = proxy.fetch('dctermsCreated', nil)
                    termsCreated.flatten.compactjoin(', ') unless termsCreated.nil?
                  end
                }
              ]
            ),
            description: data_section(
              title: 'site.object.meta-label.description',
              sections: [
                {
                  title: false,
                  collected: render_document_show_field_value(document, 'proxies.dcDescription')
                },
                {
                  title: false,
                  collected: render_document_show_field_value(document, 'proxies.dctermsTOC')
                }
              ]
            ),
            download: content_object_download,
            media: media_items,
            meta_additional: {
              geo: {
                latitude: '"' + (render_document_show_field_value(document, 'places.latitude') || '') + '"',
                longitude: '"' + (render_document_show_field_value(document, 'places.longitude') || '') + '"',
                long_and_lat: long_and_lat?,
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
              url: render_document_show_field_value(document, 'aggregations.edmIsShownAt'),
              institution_name: render_document_show_field_value(document, 'aggregations.edmDataProvider'),
              institution_country: render_document_show_field_value(document, 'europeanaAggregation.edmCountry'),
            },
            people: data_section(
              title: 'site.object.meta-label.people',
              sections: [
                {
                  title: 'site.object.meta-label.creator',
                  fields: ['agents.prefLabel'],
                  collected: document.proxies.map do |proxy|
                    proxy.fetch('dcCreator', nil)
                  end.flatten.compact,
                  url: 'q',
                  extra: [
                    {
                      field: 'agents.begin',
                      map_to: 'life.from.short'
                    },
                    {
                      field: 'agents.end',
                      map_to: 'life.to.short'
                    }
                  ]
                },
                {
                  title: 'site.object.meta-label.contributor',
                  fields: ['proxies.dcContributor']
                }
              ]
            ),
            places: data_section(
              title: 'site.object.meta-label.place',
              sections: [
                {
                  title: 'site.object.meta-label.location',
                  fields: ['proxies.dctermsSpatial']
                },
                {
                  title: 'site.object.meta-label.place-time',
                  fields: ['proxies.dcCoverage']
                }
              ]
            ),
            provenance: data_section(
              title: 'site.object.meta-label.source',
              sections: [
                {
                  title: 'site.object.meta-label.publisher',
                  fields: ['proxies.dcPublisher'],
                  url: 'aggregations.edmIsShownAt'
                },
                {
                  title: 'site.object.meta-label.provider',
                  fields: ['aggregations.edmProvider']
                },
                {
                  title: 'site.object.meta-label.data-provider',
                  fields: ['aggregations.edmDataProvider']
                },
                {
                  title: 'site.object.meta-label.providing-country',
                  fields: ['europeanaAggregation.edmCountry']
                },
                {
                  title: 'site.object.meta-label.identifier',
                  fields: ['proxies.dcIdentifier']
                },
                {
                  title: 'site.object.meta-label.provenance',
                  fields: ['proxies.dctermsProvenance']
                },
                {
                  title: 'site.object.meta-label.source',
                  fields: ['proxies.dcSource']
                },
                {
                  fields: ['timestamp_created'],
                  format_date: '%Y-%m-%d',
                  wrap: {
                    t_key: 'site.object.meta-label.timestamp_created',
                    param: :timestamp_created
                  }
                },
                {
                  fields: ['timestamp_updated'],
                  format_date: '%Y-%m-%d',
                  wrap: {
                    t_key: 'site.object.meta-label.timestamp_created',
                    param: :timestamp_updated
                  }
                }
              ]
            ),
            properties: data_section(
              title: 'site.object.meta-label.properties',
              sections: [
                {
                  title: 'site.object.meta-label.format',
                  fields: ['aggregations.webResources.dcFormat', 'proxies.dcMedium', 'proxies.dcDuration']
                },
                {
                  title: 'site.object.meta-label.extent',
                  fields: ['proxies.dctermsExtent']
                },
                {
                  title: 'site.object.meta-label.language',
                  fields: ['proxies.dcLanguage'],
                  url: 'what'
                }
              ]
            ),
            # note: view is currently showing the rights attached to the first media-item and not this value
            rights: simple_rights_label_data(render_document_show_field_value(document, 'aggregations.edmRights')),
            title: render_document_show_field_value(document, 'proxies.dcTitle'),
            type: render_document_show_field_value(document, 'proxies.dcType')
          },
          refs_rels: data_section(
            title: 'site.object.meta-label.refs-rels',
            sections: [
              {
                title: 'site.object.meta-label.relations',
                fields: ['proxies.dcRelation']
              },
              {
                title: 'site.object.meta-label.references',
                fields: ['proxies.dctermsReferences']
              }
            ]
          ),
          similar: {
            title: t('site.object.similar-items') + ':',
            more_items_query: search_path(mlt: document.id),
            items: @similar.map do |doc|
              {
                url: document_path(doc, format: 'html'),
                title: render_document_show_field_value(doc, ['dcTitleLangAware', 'title']),
                img: {
                  alt: render_document_show_field_value(doc, ['dcTitleLangAware', 'title']),
                  src: render_document_show_field_value(doc, 'edmPreview')
                }
              }
            end
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

      private

      def collect_values(fields, doc = document)
        fields.map do |field|
          render_document_show_field_value(doc, field)
        end.compact.uniq
      end

      def merge_values(fields, separator = ' ')
        collect_values(fields).join(separator)
      end

      def data_section(data)
        section_data = []
        section_labels = []

        data[:sections].map do |section|
          f_data = []
          if section[:collected]
            f_data.push(* section[:collected])
          end
          if section[:fields]
            f_data.push(*collect_values(section[:fields]))
          end
          f_data = f_data.flatten.uniq

          if f_data.size > 0
            subsection = []
            f_data.map do |f_datum|
              ob = {}
              text = f_datum

              if section[:url]
                if section[:url] == 'q'
                  ob[:url] = search_path(q: "\"#{f_datum}\"")
                elsif section[:url] == 'what'
                  ob[:url] = search_path(q: "what:\"#{f_datum}\"")
                else
                  ob[:url] = render_document_show_field_value(document, section[:url])
                end
              end

              # text manipulation

              text = if section[:format_date].nil?
                       text = f_datum
                     else
                       begin
                         date = Time.parse(f_datum)
                         date.strftime(section[:format_date])
                       rescue
                       end
                     end

              if section[:wrap]
                text = t(section[:wrap][:t_key], section[:wrap][:param] => text)
              end

              # overrides

              if section[:overrides] && text == section[:override_val]
                section[:overrides].map do |override|
                  if override[:field_title]
                    text = override[:field_title]
                  end
                  if override[:field_url]
                    ob[:url] = override[:field_url]
                  end
                end
              end

              # extra info on last

              if f_datum == f_data.last
                if !section[:extra].nil?
                  extra_info = {}
                  section[:extra].map do |xtra|
                    extra_val = render_document_show_field_value(document, xtra[:field])
                    if extra_val
                      extra_info_builder = extra_info
                      path_segments = (xtra[:map_to] || xtra[:field]).split('.')

                      path_segments.each.map do |path_segment|
                        extra_info_builder = case
                                             when extra_info_builder[path_segment]
                                               extra_info_builder[path_segment]
                                             when path_segment == path_segments.last
                                               extra_val
                                             else
                                               {}
                                             end
                      end
                    end
                    ob['extra_info'] = extra_info
                  end
                end
              end

              ob['text'] = text
              subsection << ob unless text.nil? || text.blank?
            end

            if subsection.size > 0
              section_data << subsection
              section_labels << (section[:title].nil? ? false : t(section[:title]))
            end
          end
        end

        {
          title: t(data[:title]),
          sections: section_data.each_with_index.map do |subsection, index|
            if subsection.size > 0
              {
                title: section_labels[index],
                items: subsection
              }
            else
              false
            end
          end
        } unless section_data.size == 0
      end

      def content_object_download
        links = []

        if edm_is_shown_by_download_url.present?
          links << {
            text: t('site.object.actions.download'),
            url: edm_is_shown_by_download_url
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
          if ENV['EDM_IS_SHOWN_BY_PROXY'] && document.aggregations.size > 0 && document.aggregations.first.fetch('edmIsShownBy', false)
            ENV['EDM_IS_SHOWN_BY_PROXY'] + document.fetch('about')
          else
            render_document_show_field_value(document, 'aggregations.edmIsShownBy')
          end
        end
      end

      def long_and_lat?
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

        title.size > 1 ? title[1..-1] : nil
      end

      # Media

      def media_type(url)
        ext = url[/\.[^.]*$/].downcase
        if !['.avi', '.mp3'].index(ext).nil?
          'audio'
        elsif !['.jpg', '.jpeg'].index(ext).nil?
          'image'
        elsif !['.mp4', '.ogg'].index(ext).nil?
          'video'
        elsif !['.txt', '.pdf'].index(ext).nil?
          'text'
        else
          'unknown'
        end
      end

      def simple_rights_label_data(rights)
        return nil unless rights.present?
        # global.facet.reusability.permission      Only with permission
        # global.facet.reusability.open            Yes with attribution
        # global.facet.reusability.restricted      Yes with restrictions

        prefix = t('global.facet.header.reusability') + ' '

        if rights.nil?
          nil
        elsif rights.index('http://creativecommons.org/licenses/by-nc-nd') == 0
          {
            license_public: false,
            license_human: prefix + t('global.facet.reusability.restricted')
          }
        elsif rights.index('http://creativecommons.org/licenses/by-nc-sa') == 0
          {
            license_public: true,
            license_human: prefix + t('global.facet.reusability.open')
          }
        elsif rights.index('http://www.europeana.eu/rights/rr-f') == 0
          {
            license_public: false,
            license_human: prefix + t('global.facet.reusability.permission')
          }
        elsif rights.index('http://creativecommons.org/publicdomain/mark') == 0
          {
            license_public: true,
            license_human: prefix + t('global.facet.reusability.open')
          }
        else
          {
            license_public: true,
            license_human: 'todo: map this rights value(' + rights + ')'
          }
        end
      end

      def media_items
        aggregation = document.aggregations.first
        return [] unless aggregation.respond_to?(:webResources)
        media_type = render_document_show_field_value(document, 'type').downcase
        edm_preview = render_document_show_field_value(document, 'europeanaAggregation.edmPreview', tag: false)
        primary_media = {
          preview: edm_preview,
          thumbnail: edm_preview,
          file: edm_preview,
          media_type: media_type,
          rights: simple_rights_label_data(render_document_show_field_value(document, 'aggregations.edmRights'))
        }
        if media_type == 'image'
          primary_media['is_image'] = true
        elsif media_type == 'audio'
          primary_media['is_audio'] = true
        elsif media_type == 'text'
          primary_media['is_text'] = true
        elsif media_type == 'video'
          primary_media['is_video'] = true
        else
          primary_media['is_unkown_type'] = media_type
        end
        additional_items = aggregation.webResources.map do |web_resource|
          preview_url = render_document_show_field_value(web_resource, 'about')
          preview_type = media_type(preview_url)
          item = {
            alt: preview_type + ' - ' + preview_url,
            file: preview_url,
            rights: {
              license_public: true,
              license_human: render_document_show_field_value(web_resource, 'webResourceDcRights')
            },
            media_type: preview_type
            #  json: web_resource.as_json
          }
          if preview_type == 'image'
            item['thumbnail'] = preview_url
          elsif preview_type == 'audio'
            item['thumbnail'] = 'http://europeanastatic.eu/api/image?size=BRIEF_DOC&type=SOUND'
          elsif preview_type == 'text'
            item['thumbnail'] = 'http://europeanastatic.eu/api/image?size=BRIEF_DOC&type=TEXT'
          elsif preview_type == 'video'
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
