# frozen_string_literal: true

module Portal
  ##
  # Portal search results view
  class Index < ApplicationView
    include CollectionUsingView
    include SearchableView
    include HeroImageDisplayingView
    include PaginatedView
    include UgcContentDisplayingView

    def js_vars
      super + [
        { name: 'collectionName', value: within_collection? ? current_collection.key : '' }
      ]
    end

    def grid_view_active?
      if params[:view] == 'grid'
        true
      elsif !within_collection?
        false
      else
        current_collection.settings['default_search_layout'] == 'grid'
      end
    end
    alias_method :grid_view_active, :grid_view_active?

    def bodyclass
      grid_view_active? ? 'display-grid' : nil
    end

    # TODO: move page title to localeapp
    def page_title
      mustache[:page_title] ||= begin
        [params[:q], 'Europeana - Search results'].compact.join(' - ')
      end
    end

    def form_search
      mustache[:form_search] ||= begin
        super.merge(hidden: form_search_hidden)
      end
    end

    def filters
      mustache[:filters] ||= begin
        (simple_filters + advanced_filters).select do |facet|
          # TODO: make display or not (as a filter) of each facet field
          #   configurable in the blacklight config, vs hard-coding these
          (facet[:boolean] && %w(MEDIA edm_UGC).include?(facet[:name])) || facet[:date] || facet[:items].present?
        end.each_with_index.map do |facet, index|
          # First 3 facets are always open
          facet[:filter_open] = true if index < 3
          facet
        end
      end
    end

    def simple_filters
      mustache[:simple_filters] ||= begin
        filters = facets_from_request.reject do |facet|
          blacklight_config.facet_fields[facet.name].advanced ||
            blacklight_config.facet_fields[facet.name].parent
        end
        filters.map do |facet|
          FacetPresenter.build(facet, controller).display
        end
      end
    end

    def advanced_filters
      mustache[:advanced_filters] ||= begin
        advanced_count = 0
        [
          {
            advanced_items: {
              items: facets_from_request.select do |facet|
                blacklight_config.facet_fields[facet.name].advanced &&
                  !blacklight_config.facet_fields[facet.name].parent
              end.map do |facet|
                advanced_count += 1
                FacetPresenter.build(facet, controller).display
              end.compact
            },
            advanced: advanced_count.positive?
          }
        ]
      end
    end

    def results_menu
      {
        menu_id: 'results_menu',
        button_title_prefix: t('site.results.list.per-page'),
        button_title: search_state.params[:per_page] || 12,
        items: blacklight_config.per_page.map do |pp|
          params_for_search = search_state.params_for_search(per_page: pp)
          url = if within_collection?
                  collection_path(@collection, params_for_search)
                else
                  search_path(params_for_search)
                end
          {
            is_current: pagination_per_page == pp,
            url: url,
            text: pp
          }
        end
      }
    end

    def hero
      unless @landing_page.nil?
        hero_config(@landing_page.hero_image)
      end
    end

    def query_terms
      mustache[:query_terms] ||= begin
        query_terms = [(params[:q] || [])].flatten.map do |query_term|
          content_tag(:strong, query_term)
        end
        safe_join(query_terms, ' AND ')
      end
    end

    def search_results
      mustache[:search_results] ||= begin
        @document_list.map { |doc| presenter(doc).content }
      end
    end

    def presenter(document)
      Document::SearchResultPresenter.new(document, controller, response)
    end

    def navigation
      mustache[:navigation] ||= begin
        {
          pagination: pagination_navigation
        }.reverse_merge(super)
      end
    end

    def menus
      {
        viewoptions: {
          items: [
            {
              text: t('site.results.list.results-view.grid'),
              url: search_action_path(search_state.params_for_search(view: 'grid')),
              icon_grid: true,
              is_current: params[:view] == 'grid'
            },
            {
              text: t('site.results.list.results-view.list'),
              url: search_action_path(search_state.params_for_search(view: 'list')),
              icon_list: true,
              is_current: params[:view] != 'grid'
            }
          ],
          tooltip: {
            tooltip_text: t('global.tooltips.channels.search.new-grid'),
            tooltip_id: 'new-grid-layout',
            persistent: true,
            link_class: 'filter-name'
          }
        }
      }
    end

    def facets_selected
      mustache[:facets_selected] ||= begin
        facets_selected_items.blank? ? nil : { items: facets_selected_items }
      end
    end

    def federated_search_enabled
      @collection && @collection.federation_configs.present?
    end

    def federated_search_conf
      mustache[:federated_search_conf] ||= begin
        {
          tab_items: federated_tab_items
        }
      end
    end

    def federated_tab_items
      formatted_items = @collection.federation_configs.select { |config| Foederati::Providers.get(config.provider).present? }.map do |config|
        foederati_provider = Foederati::Providers.get(config.provider)
        {
          tab_title: foederati_provider.name,
          url: federation_path(config.provider, format: :json, query: params[:q], collection: @collection),
          key: config.provider
        }
      end
      formatted_items.sort_by { |item| item[:tab_title].downcase }
    end

    def active_filter_count
      facets_selected_items.blank? ? 0 : facets_selected_items.length
    end

    def mlt_src
      return nil unless params[:mlt]
      document_path(id: params[:mlt][1..-1], format: 'html')
    end

    def content
      mustache[:content] ||= begin
        {
          ugc_content: ugc_content
        }.reverse_merge(super)
      end
    end

    def version
      { is_alpha: within_collection? && beta_collection?(current_collection) }
    end

    private

    def paginated_set
      @response
    end

    def facets_selected_items
      return @facets_selected_items unless @facets_selected_items.nil?

      @facets_selected_items = begin
        facets_from_request.map do |facet|
          FacetPresenter.build(facet, controller).filter_items
        end.flatten
      end
    end

    def uri?(string)
      uri = URI.parse(string)
      %w(http|https).include?(uri.scheme)
    rescue URI::BadURIError
      false
    rescue URI::InvalidURIError
      false
    end

    def form_search_hidden_field(name, value)
      {
        hidden_name: name,
        hidden_value: value
      }
    end

    def form_search_hidden
      fields = (params[:f] || {}).map do |f, values|
        [values].flatten.map { |v| form_search_hidden_field("f[#{f}][]", v) }
      end.flatten

      fields += (params[:range] || {}).map do |f, range|
        range.map do |k, v|
          form_search_hidden_field("range[#{f}][#{k}]", v)
        end
      end.flatten

      fields
    end
  end
end
