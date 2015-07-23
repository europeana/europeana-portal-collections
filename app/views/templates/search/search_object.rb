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
            creator: creator_title,
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
                  title: 'site.object.meta-label.subject',
                  url: 'what',
                  collected: document.proxies.map do |proxy|
                    proxy.fetch('dcSubject', nil)
                  end.flatten.compact
                },
                {
                  title: 'site.object.meta-label.has-type',
                  fields: ['proxies.edmHasType']
                },
                {
                  title: 'site.object.meta-label.concept',
                  url: 'what',
                  fields: ['aggregations.edmUgc', 'concepts.prefLabel'],
                  override_val: 'true',
                  overrides: [
                    {
                      field_title: t('site.object.meta-label.ugc'),
                      field_url: root_url + ('search?f[UGC][]=true')
                    }
                  ]
                }
              ]
            ),
            copyright: data_section(
              title: 'site.object.meta-label.copyright',
              sections: [
                {
                  title: 'site.object.meta-label.rights',
                  fields: ['proxies.dcRights', 'aggregations.edmRights']
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
                  title: 'site.object.meta-label.creation-date',
                  fields: ['proxies.dctermsIssued'],
                  collected: document.proxies.map do |proxy|
                    proxy.fetch('dctermsCreated', nil)
                  end.flatten.compact.join(', ')
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
                }
              ]
            ),
            description: data_section(
              title: 'site.object.meta-label.description',
              sections: [
                {
                  title: false,
                  collected: render_document_show_field_value(document, 'proxies.dctermsTOC')
                },
                {
                  title: false,
                  collected: render_document_show_field_value(document, 'proxies.dcDescription')
                }
              ]
            ),
            # download: content_object_download,
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
                  fields_then_fallback: true,
                  collected: document.proxies.map do |proxy|
                    proxy.fetch('dcCreator', nil)
                  end.flatten.compact,
                  url: 'q',
                  extra: [
                    {
                      field: 'agents.rdaGr2DateOfBirth',
                      map_to: 'life.from.short',
                      format_date: '%Y-%m-%d'
                    },
                    {
                      field: 'agents.rdaGr2DateOfDeath',
                      map_to: 'life.to.short',
                      format_date: '%Y-%m-%d'
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
              title: 'site.object.meta-label.location',
              sections: [
                {
                  title: 'site.object.meta-label.location',
                  fields: ['proxies.dctermsSpatial', 'places.prefLabel']
                },
                {
                  title: 'site.object.meta-label.place-time',
                  fields: ['proxies.dcCoverage']
                },
                {
                  title: 'site.object.meta-label.current-location',
                  fields: ['proxies.edmCurrentLocation']
                }
              ]
            ),
            provenance: data_section(
              title: 'site.object.meta-label.source',
              sections: [
                {
                  title: 'site.object.meta-label.provenance',
                  fields: ['proxies.dctermsProvenance']
                },
                {
                  title: 'site.object.meta-label.source',
                  fields: ['proxies.dcSource']
                },
                {
                  title: 'site.object.meta-label.publisher',
                  fields: ['proxies.dcPublisher'],
                  url: 'aggregations.edmIsShownAt'
                },
                {
                  title: 'site.object.meta-label.identifier',
                  fields: ['proxies.dcIdentifier']
                },
                {
                  title: 'site.object.meta-label.data-provider',
                  fields: ['aggregations.edmDataProvider']
                },
                {
                  title: 'site.object.meta-label.provider',
                  fields: ['aggregations.edmProvider']
                },
                {
                  title: 'site.object.meta-label.providing-country',
                  fields: ['europeanaAggregation.edmCountry']
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
                  fields: ['timestamp_update'],
                  format_date: '%Y-%m-%d',
                  wrap: {
                    t_key: 'site.object.meta-label.timestamp_updated',
                    param: :timestamp_updated
                  }
                }
              ]
            ),
            properties: data_section(
              title: 'site.object.meta-label.properties',
              sections: [
                {
                  title: 'site.object.meta-label.extent',
                  fields: ['proxies.dctermsExtent']
                },
                {
                  title: 'site.object.meta-label.duration',
                  fields: ['proxies.dcDuration']
                },
                {
                  title: 'site.object.meta-label.medium',
                  fields: ['proxies.dcMedium']
                },
                {
                  title: 'site.object.meta-label.format',
                  fields: ['aggregations.webResources.dcFormat']
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
            social_share: {
              url: URI.escape(request.original_url),
              facebook: true,
              pinterest: true,
              twitter: true,
              googleplus: true
            },
            subtitle: render_document_show_field_value(document, 'proxies.dctermsAlternative'),
            title: [render_document_show_field_value(document, 'proxies.dcTitle'), creator_title].join(' | '),
            type: render_document_show_field_value(document, 'proxies.dcType')
          },
          refs_rels: data_section(
            title: 'site.object.meta-label.refs-rels',
            sections: [
              {
                title: 'site.object.meta-label.is-part-of',
                fields: ['proxies.dctermsIsPartOf']
              },
              {
                title: 'site.object.meta-label.collection-name',
                fields: ['europeanaCollectionName']
              },
              {
                title: 'site.object.meta-label.relations',
                fields: ['proxies.dcRelation']
              },
              {
                title: 'site.object.meta-label.references',
                fields: ['proxies.dctermsReferences']
              },
              {
                title: 'site.object.meta-label.consists-of',
                fields: ['proxies.dctermsHasPart']
              },
              {
                title: 'site.object.meta-label.version',
                fields: ['proxies.dctermsHasVersion']
              },
              {
                title: 'site.object.meta-label.is-format-of',
                fields: ['proxies.dctermsIsFormatOf']
              },
              {
                title: 'site.object.meta-label.is-referenced-by',
                fields: ['proxies.dctermsIsReferencedBy']
              },
              {
                title: 'site.object.meta-label.is-replaced-by',
                fields: ['proxies.dctermsIsReplacedBy']
              },
              {
                title: 'site.object.meta-label.is-required-by',
                fields: ['proxies.dctermsIsRequiredBy']
              },
              {
                title: 'site.object.meta-label.edm.has-met',
                fields: ['proxies.edmHasMet']
              },
              {
                title: 'site.object.meta-label.edm.incorporates',
                fields: ['proxies.edmIncorporates']
              },
              {
                title: 'site.object.meta-label.edm.is-derivative-of',
                fields: ['proxies.edmIsDerivativeOf']
              },
              {
                title: 'site.object.meta-label.edm.is-representation-of',
                fields: ['proxies.edmIsRepresentationOf']
              },
              {
                title: 'site.object.meta-label.edm.is-similar-to',
                fields: ['proxies.edmIsSimilarTo']
              },
              {
                title: 'site.object.meta-label.edm.is-successor-of',
                fields: ['proxies.edmIsSuccessorOf']
              },
              {
                title: 'site.object.meta-label.edm.realises',
                fields: ['proxies.edmRealizes']
              },
              {
                title: 'site.object.meta-label.edm.was-present-at',
                fields: ['proxies.edmRealizes']
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
          rights: t('site.object.meta-label.rights-human')
        }
      end

      private

      def edm_is_shown_by_download_url
        @edm_is_shown_by_download_url ||= begin
          if ENV['EDM_IS_SHOWN_BY_PROXY'] && document.aggregations.size > 0 && document.aggregations.first.fetch('edmIsShownBy', false)
            ENV['EDM_IS_SHOWN_BY_PROXY'] + document.fetch('about')
          else
            render_document_show_field_value(document, 'aggregations.edmIsShownBy')
          end
        end
      end

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
          field_values = []

          if section[:collected]
            f_data.push(* section[:collected])
          end
          if section[:fields]
            # field_values = collect_values(section[:fields])
            field_values = []
            section[:fields].each do |field|
              values = document.fetch(field, [])
              if values.is_a? Array
                values = values - field_values
              end
              field_values << [*values]
            end
            if section[:fields_then_fallback] && field_values.size > 0
              f_data = []
            end
            f_data.push(*field_values)
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

              if f_datum == f_data.last && !section[:extra].nil?
                extra_info = {}

                section[:extra].map do |xtra|
                  extra_val = render_document_show_field_value(document, xtra[:field])
                  if !extra_val
                    next
                  end
                  if xtra[:format_date]
                    begin
                      date = Time.parse(extra_val)
                      formatted = date.strftime(xtra[:format_date])
                      extra_val = formatted
                    rescue
                    end
                  end
                  extra_info_builder = extra_info
                  path_segments = xtra[:map_to] || xtra[:field]
                  path_segments = path_segments.split('.')

                  path_segments.each.map do |path_segment|
                    is_last = path_segment == path_segments.last
                    extra_info_builder[path_segment] ||= (is_last ? extra_val : {})
                    extra_info_builder = extra_info_builder[path_segment]
                  end
                  ob['extra_info'] = extra_info
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

      # def content_object_download
      #   links = []

      #   if edm_is_shown_by_download_url.present?
      #     links << {
      #       text: t('site.object.actions.download'),
      #       url: edm_is_shown_by_download_url
      #     }
      #   end

      #   return nil unless links.present?

      #   {
      #     primary: links.first,
      #     secondary: {
      #       items: (links.size == 1) ? nil : links[1..-1]
      #     }
      #   }
      # end

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

      # Media type function normalises mime types
      # Current @mime_type variable only workd for edm_is_shown_by
      # Once it works for web_resources we change this function so
      # that  it accepts a mime type rather than a url, and

      def media_type(url)
        ext = url[/\.[^.]*$/]
        if ext.nil?
          return nil
        end

        ext = ext.downcase
        if !['.avi', '.flac', '.mp3'].index(ext).nil?
          'audio'
        elsif !['.jpg', '.jpeg'].index(ext).nil?
          'image'
        elsif !['.flv', '.mp4', '.mp2', '.mpeg', '.mpg', '.ogg'].index(ext).nil?
          'video'
        elsif !['.txt', '.pdf'].index(ext).nil?
          'text'
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
            license_human: prefix + t('global.facet.reusability.open')
          }
        end
      end

      def creator_title
        document.fetch('agents.prefLabel', []).first || render_document_show_field_value(document, 'dcCreator')
      end

      def media_items
        aggregation = document.aggregations.first
        return [] unless aggregation.respond_to?(:webResources)

        players = []
        items = []

        aggregation.webResources.map do |web_resource|
          # TODO: we're using 'document' values instead of 'web_resource' values
          # -this until the mime_type/edm_download / mimetypes start working for multiple items

          web_resource_url = render_document_show_field_value(web_resource, 'about')
          edm_resource_url = render_document_show_field_value(document, 'aggregations.edmIsShownBy')
          edm_preview = render_document_show_field_value(document, 'europeanaAggregation.edmPreview', tag: false)
          media_rights = render_document_show_field_value(web_resource, 'webResourceDcRights')
          if media_rights.nil?
            media_rights = render_document_show_field_value(document, 'aggregations.edmRights')
          end
          media_type = media_type(web_resource_url)
          media_type = media_type || media_type(render_document_show_field_value(document, 'type'))
          media_type = media_type || render_document_show_field_value(document, 'type')
          media_type = media_type.downcase

          item = {
            media_type: media_type,
            rights: simple_rights_label_data(media_rights)
          }

          item['thumbnail'] = edm_preview

          if media_type == 'image'
            item['is_image'] = true
            players << { image: true }

            # we only have a thumbnail for the first
            # - full image needed for the others
            # - metadata service needed
            if web_resource_url != edm_resource_url
              item['thumbnail'] = web_resource_url
            end
          elsif media_type == 'audio'
            item['is_audio'] = true
            players << { audio: true }
          elsif media_type == 'pdf'
            item['is_pdf'] = true
            players << { pdf: true }
          elsif media_type == 'text'
            if @mime_type == 'application/pdf'
              item['is_pdf'] = true
              players << { pdf: true }
            else
              item['is_text'] = true
            end
          elsif media_type == 'video'
            item['is_video'] = true
            players << { video: true }
          else
            item['is_unknown_type'] = render_document_show_field_value(web_resource, 'about')
          end

          # TODO: this should check the download-ability of the web resource
          if edm_is_shown_by_download_url.present?
            if @mime_type == 'application/pdf' || @mime_type == 'audio/flac'
              item['download'] = {
                url: edm_is_shown_by_download_url,
                text: t('site.object.actions.download')
              }
            else
              item['download'] = {
                url: web_resource_url,
                text: t('site.object.actions.download')
              }
            end

            item['technical_metadata'] = {
              mime_type: @mime_type
              # language: "English",
              # format: "jpg",
              # file_size: "23.2",
              # file_unit: "MB",
              # codec: "MPEG-2",
              # fps: "30",
              # fps_unit: "fps",
              # width: "1200",
              # height: "900",
              # size_unit: "pixels",
              # runtime: "34",
              # runtime_unit: "minutes"
            }
          end

          # make sure the edm_is_shown_by is the first item
          if web_resource_url == edm_resource_url
            item[:is_current] = true
            items.unshift(item)
          else
            # disable all web resources apart from the edm_is_shown_by for the beta launch
            # items << item
          end
        end
        {
          required_players: players.uniq,
          single_item: items.size == 1,
          items: items
        }
      end
    end
  end
end
