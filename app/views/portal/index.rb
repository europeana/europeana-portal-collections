module Portal
  ##
  # Portal search results view
  class Index < ApplicationView
    include FacetPresenter

    def page_title
      [params[:q], 'Europeana - Search results'].compact.join(' - ')
    end

    def form_search
      super.merge(hidden: form_search_hidden)
    end

    def filters
      facets_from_request(facet_field_names).map do |facet|
        facet_display(facet) # @see FacetPresenter
      end.compact
    end

    def results_count
      number_with_delimiter(response.total)
    end

    def has_results
      response.total > 0
    end

    def has_single_result
      response.total == 1
    end

    def has_multiple_results
      response.total > 1
    end

    def query_terms
      query_terms = [(params[:q] || [])].flatten.collect do |query_term|
        content_tag(:strong, query_term)
      end
      safe_join(query_terms, ' AND ')
    end

    def search_results
      counter = 0 + (@response.limit_value * (@response.current_page - 1))
      @document_list.collect do |doc|
        counter += 1
        search_result_for_document(doc, counter)
      end
    end

    def navigation
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
      }.reverse_merge(helpers ? helpers.navigation : {})
    end

    def facets_selected
      facets_selected_items.blank? ? nil : { items: facets_selected_items }
    end

    private

    def facets_selected_items
      return @facets_selected_items unless @facets_selected_items.nil?

      @facets_selected_items = [].tap do |items|
        facets_from_request(facet_field_names).each do |facet|
          facet.items.select { |item| facet_in_params?(facet.name, item) }.each do |item|
            items << {
              filter: facet_map(facet.name),
              value: facet_map(facet.name, item.value),
              remove: facet_item_url(facet.name, item),
              name: "f[#{facet.name}][]"
            }
          end
        end
      end
    end

    def facet_map(facet_name, facet_value = nil)
      if facet_value.nil?
        t('global.facet.header.' + facet_name.downcase)
      else
        facet_value = ('COUNTRY' == facet_name ? facet_value.gsub(/\s+/, '') : facet_value)

        mapped_value = case facet_name.upcase
          when 'CHANNEL'
            t('global.channel.' + facet_value.downcase)
          when 'PROVIDER', 'DATA_PROVIDER', 'COLOURPALETTE'
            facet_value
          else
            t('global.facet.' + facet_name.downcase + '.' + facet_value.downcase)
        end

        unless ['PROVIDER', 'DATA_PROVIDER'].include?(facet_name)
          mapped_value = mapped_value.split.map(&:capitalize).join(' ')
        end

        mapped_value
      end
    end

    def show_pagination_separator?(page_index, page_number, pages_shown)
      (page_index == 1 && @response.current_page > 2) ||
        (page_index == (pages_shown - 2) && (page_number + 1) < @response.total_pages)
    end

    def search_result_for_document(doc, counter)
      doc_type = doc.fetch(:type, nil)
      {
        object_url: document_path(doc, format: 'html') +(@channel.nil? ? '' : '?src_channel=' + @channel.id),
        link_attrs: [
          {
            name: 'data-context-href',
            value: track_document_path(doc, track_document_path_opts(counter))
          }
        ],
        title: render_index_field_value(doc, ['dcTitleLangAware', 'title']),
        text: {
          medium: truncate(render_index_field_value(doc, ['dcDescriptionLangAware', 'dcDescription']),
                           length: 277,
                           separator: ' ',
                           escape: false)
        },
        year: {
          long: render_index_field_value(doc, :year)
        },
        origin: {
          text: render_index_field_value(doc, 'dataProvider'),
          url: render_index_field_value(doc, 'edmIsShownAt')
        },
        is_image: doc_type == 'IMAGE',
        is_audio: doc_type == 'SOUND',
        is_text: doc_type == 'TEXT',
        is_video: doc_type == 'VIDEO',
        img: {
          src: render_index_field_value(doc, 'edmPreview'),
          alt: ''
        },
        agent: agent_label(doc),
        concepts: concept_labels(doc),
        item_type: {
          name: doc_type.nil? ? nil : t('site.results.list.product-' + doc_type.downcase)
        }
      }
    end

    def track_document_path_opts(counter)
      {
        per_page: params.fetch(:per_page, search_session['per_page']),
        counter: counter,
        search_id: current_search_session.try(:id)
      }
    end


    def hidden_inputs_for_search
      flatten_hash(params_for_search.except(:page, :utf8)).collect do |name, value|
        [value].flatten.collect do |v|
          {
            name: name,
            value: v.to_s
          }
        end
      end.flatten
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
      {
        items: labels[0..3].map { |c| { text: c } }
      }
    end

    def form_search_hidden
      (params[:f] || []).map do |f, vs|
        [vs].flatten.map do |v|
          {
            hidden_name: "f[#{f}][]",
            hidden_value: v
          }
        end
      end.flatten
    end
  end
end
