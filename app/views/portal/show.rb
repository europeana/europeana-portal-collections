# frozen_string_literal: true

module Portal
  class Show < ApplicationView
    include NamedEntityDisplayingView
    include Promos
    include ProJsonApiConsumingView
    include SearchableView
    include UgcContentDisplayingView

    attr_accessor :document, :debug

    delegate :field_value, to: :presenter

    # TODO: remove when new design is default
    def bodyclass
      new_design? ? 'channels-item' : ''
    end

    # TODO: remove when new design is default
    def js_var_page_name
      new_design? ? super + '-new' : super
    end

    def js_vars
      return super unless new_design?
      super.tap do |vars|
        vars.push(name: 'enabledPromos', value: js_var_enabled_promos, unquoted: true)
      end
    end

    # Are we rendering the new design?
    # TODO: remove when new design is default
    def new_design?
      @new_design
    end
    alias_method :new_design, :new_design?

    def head_links
      mustache[:head_links] ||= begin
        { items: oembed_links + super[:items] }
      end
    end

    def head_meta
      mustache[:head_meta] ||= begin
        preview = helpers.thumbnail_url_for_edm_preview(field_value('europeanaAggregation.edmPreview'))

        head_meta = [
          { meta_name: 'description', content: meta_description },
          { meta_name: 'twitter:card', content: 'summary' },
          { meta_name: 'twitter:site', content: '@EuropeanaEU' },
          { meta_property: 'og:title', content: og_title },
          { meta_property: 'og:description', content: og_description },
          { meta_property: 'fb:appid', content: '185778248173748' }
        ]
        head_meta << { meta_property: 'og:image', content: preview } unless preview.nil?
        head_meta << { meta_property: 'og:url', content: presenter.edm_landing_page }
        head_meta + super
      end
    end

    def page_content_heading
      presenter.title
    end

    def navigation
      mustache[:navigation] ||= begin
        {
          back_url: back_url_from_referer,
          back_label: t('site.navigation.breadcrumb.results_list'),
          last_label: t('site.navigation.breadcrumb.item_detail')
        }.reverse_merge(super)
      end
    end

    def include_nav_searchbar
      true
    end

    def content
      mustache[:content] ||= begin
        {
          object: {
            annotations_later: true, # TODO: remove when styleguide assumes this
            creator: presenter.creator_title,
            creators: presenter.field_group(:creators),
            concepts: presenter.field_group(:concepts),
            copyright: presenter.field_group(:copyright),
            creation_date: field_value('proxies.dctermsCreated'),
            dates: presenter.field_group(:time),
            description: presenter.field_group(:description),
            media: media_items,
            location: presenter.field_group(:location),
            origin: origin,
            people: presenter.field_group(:people),
            provenance: presenter.field_group(:provenance),
            properties: presenter.field_group(:properties),
            rights: simple_rights_label_data,
            social_share: social_share,
            subtitle: document.fetch('proxies.dctermsAlternative', []).first || document.fetch(:title, [])[1],
            title: presenter.title,
            display_title: presenter.display_title,
            type: field_value('proxies.dcType')
          },
          refs_rels: presenter.field_group(:refs_rels),
          similar: similar_items,
          suggestions: suggestions,
          named_entities: named_entities,
          ugc_content: ugc_content(true)
        }.reverse_merge(super)
      end
    end

    def labels
      mustache[:labels] ||= begin
        {
          show_more_meta: t('site.object.actions.show-more-data'),
          show_less_meta: t('site.object.actions.show-less-data'),
          rights: t('site.object.meta-label.rights-human'),
          geo: {
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
      end
    end

    def page_url
      URI.escape(request.original_url)
    end

    private

    def named_entities
      return if named_entities_data.blank?
      {
        title: t('site.object.named-entities.title'),
        data: named_entities_data,
        inline: true
      }
    end

    def named_entities_data
      mustache[:named_entities_data] ||= begin
        [
          named_entity_labels('concepts', 'what', :broader),
          named_entity_labels('agents', 'who'),
          named_entity_labels('timespans', 'when', :begin, :end),
          named_entity_labels('places', 'where', :latitude, :longitude)
        ].compact
      end
    end

    def institution_name_and_link
      is_shown_at = field_value('aggregations.edmIsShownAt')

      data_provider_or_provider = field_value('aggregations.edmDataProvider')
      data_provider_or_provider ||= field_value('aggregations.edmProvider')

      return false unless is_shown_at.present? && data_provider_or_provider.present?
      link_to(data_provider_or_provider, is_shown_at, target: '_blank')
    end

    def simple_rights_label_data
      rights = presenter.simple_rights_label_data
      licenses = document.fetch('licenses', nil)
      if !licenses.nil? && !rights.nil?
        license_expiry = licenses.first['ccDeprecatedOn']
        date = unix_time_to_local(license_expiry)
        rights[:expiry] = t('global.facet.reusability.expiry', date: date.to_formatted_s(:date))
      end
      rights
    end

    def social_share
      {
        url: presenter.edm_landing_page.present? ? URI.escape(presenter.edm_landing_page) : false,
        facebook: true,
        pinterest: true,
        twitter: true,
        googleplus: true,
        tumblr: true
      }
    end

    def origin
      {
        url: field_value('aggregations.edmIsShownAt'),
        institution_name: institution_name,
        institution_name_and_link: institution_name_and_link,
        institution_country: field_value('europeanaAggregation.edmCountry'),
        institution_canned_search: institution_canned_search,
        institution_logo: data_provider_logo_url
      }
    end

    def institution_name
      field_value('aggregations.edmDataProvider') ||
        field_value('aggregations.edmProvider')
    end

    def institution_canned_search
      edm_data_provider = field_value('aggregations.edmDataProvider')
      return false if edm_data_provider.blank?
      search_path(f: { 'DATA_PROVIDER' => [edm_data_provider] })
    end

    def similar_items
      mustache[:similar_items] ||= begin
        # Don't load similar items on the new design.
        if new_design?
          {}
        else
          {
            title: t('site.object.similar-items'),
            more_items_load: document_similar_url(document, format: 'json', mlt_query: @mlt_query),
            more_items_query: search_path(params.slice(:api_url).merge(mlt: document.id))
          }
        end
      end
    end

    def suggestions
      mustache[:suggestions] ||= begin
        # Only the new design uses suggestions.
        if new_design?
          {
            title: t('site.object.suggested-content'),
            tab_items: [
              suggestions_similar_items
            ]
          }
        else
          {}
        end
      end
    end

    def suggestions_similar_items
      {
        tab_title: t('site.object.items-similar-to-item'),
        url: document_similar_url(document, format: 'json', mlt_query: @mlt_query, per_page: 12)
      }
    end

    def oembed_links
      oembed_html.map do |_url, oembed|
        { rel: 'alternate', type: 'application/json+oembed', href: oembed[:link] }
      end
    end

    def meta_description
      mustache[:meta_description] ||= begin
        description = field_value('proxies.dcDescription')
        truncate(strip_tags(description), length: 350, separator: ' ')
      end
    end

    def og_description
      mustache[:og_description] ||= begin
        description = field_value('proxies.dcDescription')
        if description.present?
          truncate(description.split('.').first(3).join('.'), length: 200)
        else
          'Find out more on Europeana'
        end
      end
    end

    def og_title
      mustache[:og_title] ||= begin
        field_value('proxies.dcTitle') ||
          field_value('proxies.dctermsAlternative') ||
          field_value('proxies.dcDescription') ||
          field_value('proxies.dcIdentifier')
      end
    end

    def collect_values(fields, _doc = document)
      fields.map do |field|
        field_value(field)
      end.compact.uniq
    end

    def merge_values(fields, separator = ' ')
      collect_values(fields).join(separator)
    end

    def long_and_lat?(places)
      places.any? do |place|
        place[:extra_info].present? &&
          place[:extra_info][:latitude].present? &&
          place[:extra_info][:longitude].present?
      end
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
        field_value('proxies.dcTitle')
      else
        title.first
      end
    end

    def edm_preview
      @edm_preview ||= field_value('europeanaAggregation.edmPreview', tag: false)
    end

    def media_items
      @media_items ||= begin
        items = presenter.media_web_resources(per_page: 10, page: 1).map(&:media_item)
        items.first[:is_current] = true unless items.empty?

        {
          required_players: item_players,
          has_downloadable_media: has_downloadable_media?,
          external_media: field_value('aggregations.edmIsShownBy') ||
            field_value('aggregations.edmIsShownAt'),
          single_item: items.size == 1,
          empty_item: items.empty?,
          empty_item_more_link: t('site.object.preview_unavailable', institution_name_and_link: institution_name_and_link),
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
        players = %i(audio iiif image pdf video midi oembed).select do |player|
          web_resources.any? { |wr| wr.player == player }
        end
        players.map do |player|
          { player => true }
        end
      end
    end

    def has_downloadable_media?
      presenter.media_web_resources.any?(&:downloadable?)
    end

    def back_url_from_referer
      referer = request.referer
      return unless referer.present?

      search_urls = [search_url] + displayable_collections.map { |c| collection_url(c) }
      if search_urls.any? { |u| referer.match "^#{u}(\\?|$)" }
        return referer
      end
    end

    ##
    # Override method from `LocalisableView` to exlude q param
    def current_url_without_locale
      url_without_params(super)
    end

    def current_url_for_locale(_)
      url_without_params(super)
    end

    protected

    def data_provider_logo_url
      return nil unless @data_provider.present? && @data_provider.image.present?
      @data_provider.image.url(:medium)
    end

    def presenter
      @presenter ||= Document::RecordPresenter.new(document, controller)
    end
  end
end
