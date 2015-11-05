
module Portal
  class Show < ApplicationView
    attr_accessor :document, :debug

    def head_meta
      mustache[:head_meta] ||= begin
        [
          { meta_name: 'description', content: truncate(strip_tags(render_document_show_field_value(document, 'proxies.dcDescription')), length: 350, separator: ' ') }
        ] + super
      end
    end

    def page_title
      mustache[:page_title] ||= begin
        CGI.unescapeHTML([@document.fetch(:title, ['']).join(', '), 'Europeana'].compact.join(' - '))
      end
    end

    def navigation
      # skip building item breadcrumb while action caching is in use
      return helpers.navigation

      mustache[:navigation] ||= begin
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
    end

    def content
      mustache[:content] ||= begin
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
                      field_url: search_url(f: { 'UGC' => ['true'] })
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
                  collected: render_document_show_field_value(document, 'proxies.dcDescription', unescape: true)
                }
              ]
            ),
            # download: content_object_download,
            media: media_items,
            meta_additional: {
              present: @document.fetch('proxies.dctermsSpatial', []).size > 0 ||
                @document.fetch('proxies.dcCoverage', []).size > 0 ||
                @document.fetch('proxies.edmCurrentLocation', []).size > 0 ||
                (
                  @document.fetch('places.latitude', []).size > 0 &&
                  @document.fetch('places.longitude', []).size > 0
                ),
              places: data_section(
                title: 'site.object.meta-label.location',
                sections: [
                  {
                    title: 'site.object.meta-label.location',
                    fields: ['proxies.dctermsSpatial'],
                    collected: pref_label('places.prefLabel')
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
              geo: {
                latitude: '"' + (render_document_show_field_value(document, 'places.latitude') || '') + '"',
                longitude: '"' + (render_document_show_field_value(document, 'places.longitude') || '') + '"',
                long_and_lat: long_and_lat?,
                placeName: pref_label('places.prefLabel'),
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
              institution_name: render_document_show_field_value(document, 'aggregations.edmDataProvider') || render_document_show_field_value(document, 'aggregations.edmProvider'),
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
            provenance: data_section(
              title: 'site.object.meta-label.provenance',
              sections: [
                {
                  title: 'site.object.meta-label.source',
                  collected: document.aggregations.map do |aggregation|
                    if aggregation.fetch('edmUgc', nil) == 'true'
                      t('site.object.meta-label.ugc')
                    end
                  end.flatten.compact
                },
                {
                  title: 'site.object.meta-label.provenance',
                  fields: ['proxies.dctermsProvenance'],
                },
                {
                  title: 'site.object.meta-label.provenance',
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
            title: [render_document_show_field_value(document, 'proxies.dcTitle', unescape: true), creator_title].compact.join(' | '),
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
            title: t('site.object.similar-items'),
            more_items_query: search_path(mlt: document.id),
            more_items_load: document_similar_url(@document, format: 'json'),
            more_items_total: @mlt_response.present? ? @mlt_response.total : 0,
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
          named_entities: named_entity_data,
          hierarchy: @hierarchy.blank? ? nil : record_hierarchy(@hierarchy),
          thumbnail: render_document_show_field_value(document, 'europeanaAggregation.edmPreview', tag: false)
        }.reverse_merge(helpers.content)
      end
    end

    def named_entity_data
      data = [collect_concept_labels, collect_agent_labels, collect_time_labels, collect_place_labels]
      present = data.any? { |group| group[:present] }
      {
        present: present,
        data: data
      }
    end

    def collect_agent_labels
      named_entity_labels('agents', 'who')
    end

    def collect_place_labels
      named_entity_labels('places', 'where', :latitude, :longitude)
    end

    def collect_time_labels
      named_entity_labels('timespans', 'when', :begin, :end)
    end

    def collect_concept_labels
      named_entity_labels('concepts', 'what', :broader)
    end

    def named_entity_labels(edm, i18n, *args)
      fields = document.fetch(edm, []).map do |entity|
        ([:about, :prefLabel] + (args || [])).map do |f|
          named_entity_field_label(entity, f, i18n)
        end
      end.flatten.compact

      {
        title: t("site.object.named-entities.#{i18n}.title"),
        fields: fields,
        present: fields.size > 0
      }
    end

    def named_entity_field_label(entity, field, i18n)
      val = normalise_named_entity(entity[field.to_sym], agt_link_field?(field))

      if val.present?
        val = val.first if val.is_a?(Array) && val.size == 1
        multi = (val.is_a?(Hash) || val.is_a?(Array)) && (val.size > 1)

        Rails.logger.debug("normalize named entity multi: #{multi.inspect}".bold.red)

        {
          key: t(named_entity_field_label_i18n_key(field), scope: "site.object.named-entities.#{i18n}"),
          val: multi ? nil : val,
          vals: multi ? val : nil,
          multi: multi,
          agt_link: agt_link_field?(field)
        }
      end
    end

    def named_entity_field_label_i18n_key(field)
      map = { about: 'term', prefLabel: 'label' }
      map.key?(field) ? map[field] : field
    end

    def agt_link_field?(field)
      [:about, :broader].include?(field)
    end

    def normalise_named_entity(named_entity, agt_link = false)
      return [] if named_entity.nil?
      return named_entity unless named_entity.is_a?(Hash)
      return named_entity[:def] if named_entity.key?(:def) && named_entity.size == 1

      named_entity.map do |key, val|
        if key && val.nil?
          { val: key, key: nil, agt_link: agt_link }
        else
          { key: key, val: val, agt_link: agt_link }
        end
      end
    end

    def simple_rights_label_data
      mustache[:simple_rights_label_data] ||= begin
        Document::RecordPresenter.new(document, controller).simple_rights_label_data
      end
    end

    def labels
      mustache[:labels] ||= begin
        {
          show_more_meta: t('site.object.actions.show-more-data'),
          show_less_meta: t('site.object.actions.show-less-data'),
          rights: t('site.object.meta-label.rights-human')
        }
      end
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

    def data_section_field_values(section)
      fields = (section[:fields] || []).map do |field|
        @document.fetch(field, [])
      end

      if section[:fields_then_fallback] && fields.present?
        values = fields
      else
        values = [section[:collected]] + fields
      end

      values.flatten.compact.uniq
    end

    def data_section_field_subsection(section)
      field_values = data_section_field_values(section)

      subsection = field_values.map do |val|
        {}.tap do |item|
          item[:text] = val

          if section[:url]
            if section[:url] == 'q'
              item[:url] = search_path(q: "\"#{val}\"")
            elsif section[:url] == 'what'
              item[:url] = search_path(q: "what:\"#{val}\"")
            else
              item[:url] = render_document_show_field_value(document, section[:url])
            end
          end

          # text manipulation
          item[:text] = format_date(val, section[:format_date])

          # overrides
          if section[:overrides] && item[:text] == section[:override_val]
            section[:overrides].map do |override|
              if override[:field_title]
                item[:text] = override[:field_title]
              end
              if override[:field_url]
                item[:url] = override[:field_url]
              end
            end
          end

          # extra info on last
          if val == field_values.last && !section[:extra].nil?
            item[:extra_info] = data_section_nested_hash(section[:extra])
          end
        end
      end

      subsection.reject { |item| item[:text].blank? }
    end

    def data_section(data)
      sections = data[:sections].map do |section|
        {
          title: section[:title].nil? ? false : t(section[:title]),
          items: data_section_field_subsection(section)
        }
      end

      sections.reject! { |section| section[:items].blank? }

      sections.blank? ? nil : {
        title: t(data[:title]),
        sections: sections
      }
    end

    ##
    # Creates a nested hash of field values for Mustache template
    def data_section_nested_hash(mappings)
      {}.tap do |hash|
        mappings.each do |mapping|
          val = render_document_show_field_value(@document, mapping[:field])
          if val.present?
            keys = (mapping[:map_to] || mapping[:field]).split('.')
            last = keys.pop

            context = hash
            keys.each do |k|
              context[k] ||= {}
              context = context[k]
            end
            context[last] = format_date(val, mapping[:format_date])
          end
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
      title = document.fetch(:title, nil)

      if title.blank?
        render_document_show_field_value(document, 'proxies.dcTitle')
      else
        title.first
      end
    end

    def pref_label(field_name)
      val = @document.fetch(field_name, [])
      pref = nil
      if val.size > 0
        if val.is_a?(Array)
          val[0]
        else
          pref = val[0][I18n.locale.to_sym]
          if pref.size > 0
            pref[0]
          else
            val[0][:en]
          end
        end
      end
    end

    def creator_title
      @creator_title ||= begin
        document.fetch('agents.prefLabel', []).first ||
          render_document_show_field_value(document, 'dcCreator') ||
          render_document_show_field_value(document, 'proxies.dcCreator')
      end
    end

    def edm_preview
      @edm_preview ||= render_document_show_field_value(document, 'europeanaAggregation.edmPreview', tag: false)
    end

    def media_items
      @media_items ||= begin
        items = presenter.media_web_resources(per_page: 10, page: 1).map(&:media_item)
        items.first[:is_current] = true unless items.size == 0

        {
          required_players: item_players,
          has_downloadable_media: has_downloadable_media?,
          external_media: render_document_show_field_value(document, 'aggregations.edmIsShownBy') ||
            render_document_show_field_value(document, 'aggregations.edmIsShownAt'),
          single_item: items.size == 1,
          empty_item: items.size == 0,
          items: items,
          # The page parameter gets added by the javascript - base url needed here
          more_thumbs_url: document_media_path(document, format: 'json'),
          # if we're already on page 2 the page number here should be 3
          more_thumbs_page: document_media_path(document, page: 2, format: 'json'),
          more_thumbs_total: presenter.media_web_resources.total_count
        }
      end
    end

    def item_players
      @item_players ||= begin
        web_resources = presenter.media_web_resources
        players = [:audio, :iiif, :image, :pdf, :video].select do |player|
          web_resources.any? { |wr| wr.player == player }
        end
        players.map do |player|
          { player => true }
        end
      end
    end

    def has_downloadable_media?
      presenter.media_web_resources.any? { |wr| wr.downloadable? }
    end

    def presenter
      @presenter ||= Document::RecordPresenter.new(document, controller)
    end

    def format_date(text, format)
      return text if format.nil?
      Time.parse(text).strftime(format)
    rescue ArgumentError
      text
    end
  end
end
