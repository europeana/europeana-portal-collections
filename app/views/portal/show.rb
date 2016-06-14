module Portal
  class Show < ApplicationView
    attr_accessor :document, :debug

    def head_links
      s = super
      mustache[:head_links] ||= {
        items: [
          { rel: 'canonical', href: document_url(document, format: 'html') }
        ] + oembed_links + s[:items]
      }
    end

    def oembed_links
      oembed_html.map do |_url, oembed|
        { rel: 'alternate', type: 'application/json+oembed', href: oembed[:link] }
      end
    end

    def head_meta
      mustache[:head_meta] ||= begin
        landing = render_document_show_field_value(document, 'europeanaAggregation.edmLandingPage')
        preview = record_preview_url(render_document_show_field_value(document, 'europeanaAggregation.edmPreview', unescape: true))

        head_meta = [
          { meta_name: 'description', content: meta_description },
          { meta_name: 'twitter:card', content: 'summary' },
          { meta_name: 'twitter:site', content: '@EuropeanaEU' },
          { meta_property: 'og:sitename', content: 'Europeana Collections' },
          { meta_property: 'og:title', content: og_title },
          { meta_property: 'og:description', content: og_description },
          { meta_property: 'fb:appid', content: '185778248173748' }
        ]
        head_meta << { meta_property: 'og:image', content: preview } unless preview.nil?
        head_meta << { meta_property: 'og:url', content: landing } unless landing.nil?
        head_meta + super
      end
    end

    def page_title
      mustache[:page_title] ||= begin
        title = [render_document_show_field_value(document, 'proxies.dcTitle', unescape: true), creator_title]
        CGI.unescapeHTML(title.compact.join(' | ')) + ' - Europeana'
      end
    end

    def navigation
      mustache[:navigation] ||= begin
        { back_url: back_url_from_referer }.reverse_merge(helpers.navigation)
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
                  fields: ['proxies.dcType'],
                  collected: document.proxies.map do |proxy|
                    proxy.fetch('dcType', nil)
                  end.flatten.compact,
                  search_field: 'what',
                  quoted: true
                },
                {
                  title: 'site.object.meta-label.subject',
                  search_field: 'what',
                  quoted: true,
                  collected: document.proxies.map do |proxy|
                    proxy.fetch('dcSubject', nil)
                  end.flatten.compact
                },
                {
                  title: 'site.object.meta-label.has-type',
                  search_field: 'what',
                  fields: ['proxies.edmHasType']
                },
                {
                  title: 'site.object.meta-label.medium',
                  search_field: 'proxy_dcterms_medium',
                  quoted: true,
                  fields: 'proxies.dctermsMedium'
                }
              ]
            ),
            copyright: data_section(
              title: 'site.object.meta-label.copyright',
              sections: [
                {
                  title: 'site.object.meta-label.rights',
                  fields: ['proxies.dcRights', 'aggregations.edmRights'],
                  ga_data: 'dimension5'
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
              present: document.fetch('proxies.dctermsSpatial', []).size > 0 ||
                document.fetch('proxies.dcCoverage', []).size > 0 ||
                document.fetch('proxies.edmCurrentLocation', []).size > 0 ||
                (
                  document.fetch('places.latitude', []).size > 0 &&
                  document.fetch('places.longitude', []).size > 0
                ),
              places: data_section(
                title: 'site.object.meta-label.location',
                sections: [
                  {
                    title: 'site.object.meta-label.location',
                    fields: ['proxies.dctermsSpatial'],
                    collected: pref_label('places.prefLabel')
                    #collected: document.fetch('places.prefLabel', []).first,
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
                #placeName: document.fetch('places.prefLabel', []).first,
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
              institution_name_and_link: institution_name_and_link,
              institution_country: render_document_show_field_value(document, 'europeanaAggregation.edmCountry'),
              institution_canned_search: render_document_show_field_value(document, 'aggregations.edmDataProvider') ?
                search_path(f: { 'DATA_PROVIDER' => [render_document_show_field_value(document, 'aggregations.edmDataProvider')] }) : false
            },
            people: data_section(
              title: 'site.object.meta-label.people',
              sections: [
                {
                  title: 'site.object.meta-label.creator',
                  entity_name: 'agents',
                  entity_proxy_field: 'dcCreator',
                  search_field: 'who',
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
                  entity_name: 'agents',
                  entity_proxy_field: 'dcContributor',
                  search_field: 'who'
                },
                {
                  title: 'site.object.meta-label.subject',
                  entity_name: 'agents',
                  entity_proxy_field: 'dcSubject',
                  search_field: 'who'
                },
                {
                  title: 'site.object.meta-label.publisher',
                  entity_name: 'agents',
                  entity_proxy_field: 'dcPublisher',
                  search_field: 'who'
                },
                {
                  title: 'site.object.meta-label.rights',
                  entity_name: 'agents',
                  entity_proxy_field: 'dcRights',
                  search_field: 'who'
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
                  fields: ['proxies.dcSource'],
                  exclude_vals: ['ugc', 'UGC']
                },
                {
                  title: 'site.object.meta-label.publisher',
                  fields: ['proxies.dcPublisher'],
                  search_field: 'proxy_dc_publisher',
                  quoted: true
                },
                {
                  title: 'site.object.meta-label.identifier',
                  fields: ['proxies.dcIdentifier']
                },
                {
                  title: 'site.object.meta-label.data-provider',
                  fields: ['aggregations.edmDataProvider'],
                  search_field: 'DATA_PROVIDER',
                  ga_data: 'dimension3',
                  quoted: true
                },
                {
                  title: 'site.object.meta-label.provider',
                  fields: ['aggregations.edmProvider'],
                  search_field: 'PROVIDER',
                  ga_data: 'dimension4',
                  quoted: true
                },
                {
                  title: 'site.object.meta-label.providing-country',
                  fields: ['europeanaAggregation.edmCountry'],
                  search_field: 'COUNTRY',
                  ga_data: 'dimension2',
                  quoted: true
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
                  fields: ['proxies.dcFormat'],
                  search_field: 'proxy_dc_format',
                  quoted: true
                },
                {
                  title: 'site.object.meta-label.language',
                  fields: ['proxies.dcLanguage'],
                  search_field: 'dc_language',
                  quoted: false
                }
              ]
            ),
            rights: simple_rights_label_data,
            social_share: {
              url: URI.escape(document_url(document, format: 'html')),
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
                fields: ['proxies.dctermsIsPartOf'],
                search_field: 'proxy_dcterms_isPartOf',
                quoted: true
              },
              {
                title: 'site.object.meta-label.collection-name',
                fields: ['europeanaCollectionName'],
                search_field: 'europeana_collectionName'
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
          similar: @hierarchy.blank? ? {
            title: t('site.object.similar-items'),
            more_items_query: search_path(mlt: document.id),
            more_items_load: document_similar_url(document, format: 'json'),
            more_items_total: @mlt_response.present? ? @mlt_response.total : 0,
            items: @similar.map do |doc|
              {
                url: document_path(doc, format: 'html'),
                title: render_document_show_field_value(doc, ['dcTitleLangAware', 'title']),
                img: {
                  alt: render_document_show_field_value(doc, ['dcTitleLangAware', 'title']),
                  # temporary fix until API contains correct image url
                  # src: render_document_show_field_value(doc, 'edmPreview'),
                  src: record_preview_url(render_document_show_field_value(doc, 'edmPreview'), 400)
                }
              }
            end
          } : false,
          named_entities: named_entity_data,
          hierarchy: @hierarchy.blank? ? nil : record_hierarchy(@hierarchy),
          thumbnail: render_document_show_field_value(document, 'europeanaAggregation.edmPreview', tag: false)
        }.reverse_merge(helpers.content)
      end
    end

    def institution_name_and_link
      is_shown_at = render_document_show_field_value(document, 'aggregations.edmIsShownAt')
      is_shown_by = nil # render_document_show_field_value(document, 'aggregations.edmIsShownBy')
      at_or_by = is_shown_at || is_shown_by

      provider = render_document_show_field_value(document, 'aggregations.edmProvider')
      data_provider = render_document_show_field_value(document, 'aggregations.edmDataProvider')
      data_provider_or_provider = data_provider || provider

      if at_or_by && data_provider_or_provider
        '<a class="cap" target="_blank" href="' +
          at_or_by + '">' + data_provider_or_provider +
          ' <svg class="icon icon-linkout"><use xlink:href="#icon-linkout"/></svg></a>'
      else
        false
      end
    end

    def named_entity_data
      data = [collect_concept_labels, collect_agent_labels, collect_time_labels, collect_place_labels].compact
      {
        title: t('site.object.named-entities.title'),
        data: data,
        inline: true,
      } unless data.size == 0
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
      fields = named_entity_fields(edm, i18n, *args)
      return nil if fields.empty?
      {
        title: t("site.object.named-entities.#{i18n}.title"),
        fields: fields
      }
    end

    def named_entity_fields(edm, i18n, *args)
      document.fetch(edm, []).map do |entity|
        properties = [:about, :prefLabel] + (args || [])
        properties.map do |f|
          named_entity_field_label(entity, f, i18n)
        end
      end.flatten.compact
    end

    def named_entity_field_label(entity, field, i18n)
      val = normalise_named_entity(entity[field.to_sym], named_entity_link_field?(field))

      if val.present?
        val = val.first if val.is_a?(Array) && val.size == 1
        multi = (val.is_a?(Hash) || val.is_a?(Array)) && (val.size > 1)

        {
          key: t(named_entity_field_label_i18n_key(field), scope: "site.object.named-entities.#{i18n}"),
          val: multi ? nil : val,
          vals: multi ? val : nil,
          multi: multi,
          foldable_link: named_entity_link_field?(field)
        }
      end
    end

    def named_entity_field_label_i18n_key(field)
      map = { about: 'term', prefLabel: 'label' }
      map.key?(field) ? map[field] : field
    end

    def named_entity_link_field?(field)
      [:about, :broader].include?(field)
    end

    def normalise_named_entity(named_entity, foldable_link = false)
      return [] if named_entity.nil?
      return named_entity unless named_entity.is_a?(Hash)
      return named_entity[:def] if named_entity.key?(:def) && named_entity.size == 1

      named_entity.map do |key, val|
        if key && val.nil?
          { val: key, key: nil, foldable_link: foldable_link }
        else
          { key: key, val: val, foldable_link: foldable_link }
        end
      end
    end

    def simple_rights_label_data
      rights = mustache[:simple_rights_label_data] ||= begin
        Document::RecordPresenter.new(document, controller).simple_rights_label_data
      end
      licenses = document.fetch('licenses', nil)
      if !licenses.nil? && !rights.nil?
        license_expiry = licenses.first['ccDeprecatedOn']
        date = unix_time_to_local(license_expiry)
        rights[:expiry] = t('global.facet.reusability.expiry', date: date.to_formatted_s(:date))
      end
      rights
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

    def page_url
      URI.escape(request.original_url)
    end

    private

    def meta_description
      mustache[:meta_description] ||= begin
        description = render_document_show_field_value(document, 'proxies.dcDescription')
        truncate(strip_tags(description), length: 350, separator: ' ')
      end
    end

    def og_description
      mustache[:og_description] ||= begin
        description = render_document_show_field_value(document, 'proxies.dcDescription', unescape: true)
        if description.present?
          truncate(description.split('.').first(3).join('.'), length: 200)
        else
          'Find out more on Europeana'
        end
      end
    end

    def og_title
      mustache[:og_title] ||= begin
        render_document_show_field_value(document, 'proxies.dcTitle', unescape: true) ||
          render_document_show_field_value(document, 'proxies.dctermsAlternative') ||
          render_document_show_field_value(document, 'proxies.dcDescription') ||
          render_document_show_field_value(document, 'proxies.dcIdentifier')
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

    def data_section_field_values(section)
      if section[:entity_name] && section[:entity_proxy_field]
        proxy_fields = document.fetch("proxies.#{section[:entity_proxy_field]}", [])
        entities = document.fetch(section[:entity_name], [])
        entities.select! { |entity| proxy_fields.include?(entity[:about]) }
        fields = entities.map { |entity| entity.fetch('prefLabel', entity.fetch('foafName', entity[:about])) }
      elsif section[:fields]
        fields = [section[:fields]].flatten.map do |field|
          document.fetch(field, [])
        end
      else
        fields = []
      end

      fields = fields.flatten.compact.uniq

      if section[:exclude_vals].present?
        fields = fields - section[:exclude_vals]
      end

      return fields if section[:fields_then_fallback] && fields.present?

      fields = ([section[:collected]] + fields).flatten.compact.uniq
      return fields if section[:entity_name] && section[:entity_proxy_field]

      entity_uris = document.fetch('agents.about', []) || []
      fields.reject { |field| entity_uris.include?(field) }
    end

    def data_section_field_search_path(val, field, quoted)
      return unless val.is_a?(String)

      search_val = val.gsub(/[()\[\]<>]/, '')

      format = quoted ? '"%s"' : '(%s)'
      search_val = sprintf(format, search_val)

      search_path(q: "#{field}:#{search_val}")
    end

    def data_section_field_subsection(section)
      field_values = data_section_field_values(section)

      field_values.compact.map do |val|
        {}.tap do |item|
          item[:text] = val
          if section[:url]
            item[:url] = render_document_show_field_value(document, section[:url])
          elsif section[:search_field]
            item[:url] = data_section_field_search_path(val, section[:search_field], section[:quoted])
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

          if section[:ga_data]
            item[:ga_data] = section[:ga_data]
          end

          # extra info on last
          if val == field_values.last && !section[:extra].nil?
            item[:extra_info] = data_section_nested_hash(section[:extra])
          end
        end
      end
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
          val = render_document_show_field_value(document, mapping[:field])
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
        players = [:audio, :iiif, :image, :pdf, :video, :midi, :oembed].select do |player|
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
      return text if format.nil? || (text !=~ /^.+-/)
      Time.parse(text).strftime(format)
    rescue ArgumentError
      text
    end

    def back_url_from_referer
      referer = request.referer
      return unless referer.present?

      search_urls = [search_url] + displayable_collections.map { |c| collection_url(c) }
      if search_urls.any? { |u| referer.match "^#{u}(\\?|$)" }
        return referer
      end
    end
  end
end
