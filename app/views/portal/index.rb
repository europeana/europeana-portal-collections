module Portal
  ##
  # Portal search results view
  class Index < ApplicationView
    include SearchableView

    def js_vars
      [{ name: 'pageName', value: 'portal/index' }]
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
          (facet[:boolean] && !facet[:title] == 'MEDIA') || facet[:date] || facet[:items].present?
        end.each_with_index.map do |facet,index|
          # First 3 facets are always open
          facet[:filter_open] = true if index < 3
          # Add the media facet under type
          if facet[:name] == 'TYPE'
            merged_facet = FacetPresenter.build(facet_by_field_name('MEDIA'), controller).display
            if merged_facet
              facet[:items] << { is_separator: true }
              facet[:items] << merged_facet
            end
          end
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
            advanced: advanced_count > 0
          }
        ]
      end
    end

    def results_count
      mustache[:results_count] ||= begin
        number_with_delimiter(response.total)
      end
    end

    def results_range
      result_number_from = ((@response.current_page - 1) * @response.limit_value) + 1
      result_number_to   = [result_number_from + @response.limit_value - 1, response.total].min
      result_number_from.to_s + ' - ' + result_number_to.to_s
    end

    def has_results
      mustache[:has_results] ||= begin
        response.total > 0
      end
    end

    def has_single_result
      mustache[:has_single_result] ||= begin
        response.total == 1
      end
    end

    def has_multiple_results
      mustache[:has_multiple_results] ||= begin
        response.total > 1
      end
    end

    def results_menu
      {
        menu_id: 'results_menu',
        button_title_prefix: t('site.results.list.per-page'),
        button_title: search_state.params[:per_page] || 12,
        items: blacklight_config.per_page.map do |pp|
          params_for_search = search_state.params_for_search(per_page: pp)
          url = if @collection.present?
                  collection_path(@collection, params_for_search)
                else
                  search_path(params_for_search)
                end
          {
            is_current: @response.limit_value == pp,
            url: url,
            text: pp
          }
        end
      }
    end

    def query_terms
      mustache[:query_terms] ||= begin
        query_terms = [(params[:q] || [])].flatten.collect do |query_term|
          content_tag(:strong, query_term)
        end
        safe_join(query_terms, ' AND ')
      end
    end

    def search_results
      mustache[:search_results] ||= begin
        @document_list.map { |doc| search_result_for_document(doc) }
      end
    end

    def navigation
      mustache[:navigation] ||= begin
        pages = pages_of_search_results
        {
          pagination: {
            prev_url: previous_page_url,
            next_url: next_page_url,
            is_first_page: @response.first_page?,
            is_last_page: @response.last_page?,
            pages: pages.collect.each_with_index do |page, i|
              {
                url: Kaminari::Helpers::Page.new(self, page: page.number).url,
                index: number_with_delimiter(page.number),
                is_current: (@response.current_page == page.number),
                separator: show_pagination_separator?(i, page.number, pages.size)
              }
            end
          }
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

    def active_filter_count
      facets_selected_items.blank? ? 0 : facets_selected_items.length
    end

    def collection_data
      mustache[:collection_data] ||= begin
        if within_collection?
          collection = current_collection
          {
            name: collection.key,
            label: collection.landing_page.title,
            url: collection_url(collection),
            def_view: collection.settings['default_search_layout']
          }
        end
      end
    end
    alias_method :channel_data, :collection_data

    private

    def facets_selected_items
      return @facets_selected_items unless @facets_selected_items.nil?

      @facets_selected_items = begin
        facets_from_request.map do |facet|
          FacetPresenter.build(facet, controller).filter_items
        end.flatten
      end
    end

    def show_pagination_separator?(page_index, page_number, pages_shown)
      (page_index == 1 && @response.current_page > 2) ||
        (page_index == (pages_shown - 2) && (page_number + 1) < @response.total_pages)
    end

    def search_result_for_document(doc)
      doc_type = doc.fetch(:type, nil)
      {
        object_url: document_path(doc, format: 'html', q: params[:q], l: params_to_log(doc)),
        title: search_result_title(doc),
        text: search_result_text(doc),
        year: search_result_year(doc),
        origin: search_result_origin(doc),
        is_image: doc_type == 'IMAGE',
        is_audio: doc_type == 'SOUND',
        is_text: doc_type == 'TEXT',
        is_video: doc_type == 'VIDEO',
        img: search_result_img(doc),
        agent: agent_label(doc),
        concepts: concept_labels(doc),
        item_type: search_result_item_type(doc_type)
      }
    end

    def params_to_log(doc)
      {
        p: params.slice(:q, :f, :mlt, :range),
        r: doc.rank,
        t: response.total
      }
    end

    def uri?(string)
      uri = URI.parse(string)
      %w(http|https).include?(uri.scheme)
    rescue URI::BadURIError
      false
    rescue URI::InvalidURIError
      false
    end

    def search_result_title(doc)
      truncate(render_index_field_value(doc, ['dcTitleLangAware', 'title'], unescape: true),
               length: 225,
               separator: ' ',
               escape: false)
    end

    def search_result_text(doc)
      {
        medium: truncate(render_index_field_value(doc, ['dcDescriptionLangAware', 'dcDescription'], unescape: true),
                         length: 277,
                         separator: ' ',
                         escape: false)
      }
    end

    def search_result_year(doc)
      {
        long: render_index_field_value(doc, :year)
      }
    end

    def search_result_origin(doc)
      {
        text: render_index_field_value(doc, 'dataProvider'),
        url: render_index_field_value(doc, 'edmIsShownAt')
      }
    end

    def search_result_img(doc)
      {
        src: thumbnail_url(doc),
        alt: ''
      }
    end

    def search_result_item_type(doc_type)
      {
        name: doc_type.nil? ? nil : t('site.results.list.product-' + doc_type.downcase.sub('_3d', '3D'))
      }
    end

    def thumbnail_url(doc)
      edm_preview = render_index_field_value(doc, 'edmPreview')
      return nil if edm_preview.blank?

      @api_uri ||= URI.parse(Europeana::API.url)

      uri = URI.parse(edm_preview)
      query = Rack::Utils.parse_query(uri.query)
      query['size'] = 'w400'

      uri.host = @api_uri.host
      uri.path = @api_uri.path + '/thumbnail-by-url.json'
      uri.query = query.to_query

      uri.to_s
    end

    def previous_page_url
      prev_page = Kaminari::Helpers::PrevPage.new(self, current_page: @response.current_page)
      prev_page.url
    end

    def next_page_url
      next_page = Kaminari::Helpers::NextPage.new(self, current_page: @response.current_page)
      next_page.url
    end

    def pages_of_search_results
      opts = {
        total_pages: @response.total_pages,
        current_page: @response.current_page,
        per_page: @response.limit_value,
        remote: false,
        window: 3
      }
      pages = []
      Kaminari::Helpers::Paginator.new(self, opts).each_relevant_page do |p|
        pages << p
      end
      pages
    end

    def agent_label(doc)
      label = render_index_field_value(doc, 'edmAgentLabelLangAware')
      label ||= render_index_field_value(doc, 'edmAgentLabel')
      label ||= render_index_field_value(doc, 'dcCreator')
      label
    end

    def concept_labels(doc)
      labels = doc.fetch('edmConceptPrefLabelLangAware', []) || []
      return nil if labels.is_a?(Hash)
      {
        items: labels[0..3].map { |c| { text: c } }
      }
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

      fields << form_search_hidden_field('mlt', params[:mlt]) if params.key?(:mlt)
      fields
    end
  end
end
