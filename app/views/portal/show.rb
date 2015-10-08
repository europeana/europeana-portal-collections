module Portal
  class Show < ApplicationView
    attr_accessor :document, :debug

    def head_meta
      [
        { meta_name: 'description', content: truncate(strip_tags(render_document_show_field_value(document, 'proxies.dcDescription')), length: 350, separator: ' ') }
      ] + super
    end

    def page_title
      [@document.fetch(:title, ['']).join(', '), 'Europeana'].compact.join(' - ')
    end

    def navigation
      query_params = current_search_session.try(:query_params) || {}

      if search_session['counter']
        per_page = (search_session['per_page'] || default_per_page).to_i
        counter = search_session['counter'].to_i

        query_params[:per_page] = per_page unless search_session['per_page'].to_i == default_per_page
        query_params[:page] = ((counter - 1) / per_page) + 1
      end

      # use nil rather than "search_action_path(only_path: true)" to stop pointless breadcrumb
      back_link_url = query_params.empty? ? nil : url_for(query_params)

      navigation = {
        back_url: back_link_url,
        next_prev: {}
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
      navigation.reverse_merge(helpers.navigation)
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
                title: 'site.object.meta-label.timestamp-created',
                fields: ['timestamp_created'],
                format_date: '%Y-%m-%d'
              },
              {
                title: 'site.object.meta-label.timestamp-updated',
                fields: ['timestamp_update'],
                format_date: '%Y-%m-%d'
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
          rights: simple_rights_label_data,
          social_share: {
            url: URI.escape(request.original_url),
            facebook: true,
            pinterest: true,
            twitter: true,
            googleplus: true
          },
          subtitle: document.fetch('proxies.dctermsAlternative', []).first || document.fetch(:title, [])[1],
          title: [render_document_show_field_value(document, 'proxies.dcTitle'), creator_title].compact.join(' | '),
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
          more_items_load: request.original_url.split('.html')[0] + '/similar.json',
          more_items_total: 100,
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
        },
        hierarchy: @document.hierarchy.blank? ? nil : document_hierarchy,
        thumbnail: render_document_show_field_value(document, 'europeanaAggregation.edmPreview', tag: false)
      }.reverse_merge(helpers.content)
    end

    def simple_rights_label_data
      Document::RecordPresenter.new(document, controller).simple_rights_label_data
    end

    def labels
      {
        show_more_meta: t('site.object.actions.show-more-data'),
        show_less_meta: t('site.object.actions.show-less-data'),
        rights: t('site.object.meta-label.rights-human')
      }
    end

    private

    def document_hierarchy
      {
        parent: hierarchy_node(@document.hierarchy[:parent]),
        siblings: {
          items: @document.hierarchy[:preceding_siblings].map { |item| hierarchy_node(item) } +
            [hierarchy_node(@document.hierarchy[:self])] +
            @document.hierarchy[:following_siblings].map { |item| hierarchy_node(item) }
        },
        children: {
          items: @document.hierarchy[:children].map { |item| hierarchy_node(item) }
        }
      }
    end

    def hierarchy_node(item)
      return nil unless item.present?
      {
        title: render_document_show_field_value(item, 'title'),
        index: render_document_show_field_value(item, 'index'),
        url: document_path(item, format: 'html'),
        is_current: (item.id == @document.id)
      }
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

    def creator_title
      document.fetch('agents.prefLabel', []).first || render_document_show_field_value(document, 'dcCreator')
    end

    def edm_preview
      @edm_preview ||= render_document_show_field_value(document, 'europeanaAggregation.edmPreview', tag: false)
    end

    def media_items

      items = presenter.media_web_resources(per_page: 4, page: 1).map do |web_resource|
        Document::WebResourcePresenter.new(web_resource, document, controller).media_item
      end
      items.first[:is_current] = true unless items.size == 0

      {
        required_players: item_players(items),
        single_item: items.size == 1,
        empty_item: items.size == 0,
        items: items,

        # The page parameter gets added by the javascript - base url needed here
        more_thumbs_url: document_media_path(document, format: 'json'),

        # if we're already on page 2 the page number here should be 3
        more_thumbs_page: document_media_path(document, page: 2, format: 'json'),

        # this is inefficient, but works
        more_thumbs_total: presenter.media_web_resources(per_page: 111111111).size
      }
    end

    def item_players(items)
      players = [:audio, :iiif, :image, :pdf, :video].select do |player|
        items.any? { |item| item.fetch("is_#{player}".to_sym, false) }
      end
      players.map do |player|
        { player => true }
      end
    end

    def presenter
      @presenter ||= Document::RecordPresenter.new(document, controller)
    end
  end
end
