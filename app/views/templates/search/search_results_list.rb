module Templates
  module Search
    class SearchResultsList < ApplicationView
      def filters
        facets_from_request(facet_field_names).collect do |facet|
          facet_config = blacklight_config.facet_fields[facet.name]
          if facet_config.range
            range_facet_template_data(facet)
          else
            simple_facet_template_data(facet)
          end
        end
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
          },
          global: navigation_global
        }
        
      end

      private

      def facet_map(facet_name, facet_value = nil)
        if facet_value.nil?
          t('global.facet.header.' + facet_name.downcase)
        else
          facet_value = ('COUNTRY' == facet_name ? facet_value.gsub(/\s+/, '') : facet_value)
          
          case facet_name.upcase
            when 'CHANNEL'
              t('global.channel.' + facet_value.downcase)
            when 'PROVIDER'
              facet_value
            when 'DATA_PROVIDER'
              facet_value
            else
              t('global.facet.' + facet_name.downcase + '.' + facet_value.downcase)
          end
        end
      end

      def show_pagination_separator?(page_index, page_number, pages_shown)
        (page_index == 1 && @response.current_page > 2) ||
        (page_index == (pages_shown - 2) && (page_number + 1) < @response.total_pages)
      end

      def search_result_for_document(doc, counter)
        {
          object_url: url_for_document(doc),
          link_attrs: [
            {
              name: 'data-context-href',
              value: track_document_path(doc, track_document_path_opts(counter))
            }
          ],
          title: render_index_field_value(doc, :dcTitleLangAware),
          text: {
            medium: truncate(render_index_field_value(doc, 'dcDescription'),
                             length: 140,
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
          is_image: doc.fetch(:type) == 'IMAGE',
          is_audio: doc.fetch(:type) == 'SOUND',
          is_text: doc.fetch(:type) == 'TEXT',
          is_video: doc.fetch(:type) == 'VIDEO',
          img: {
            rectangle: {
              src: render_index_field_value(doc, 'edmPreview'),
              alt: ''
            }
          },
          agent: agent_label(doc),
          concepts: concept_labels(doc),
          item_type: {
            name: t('site.results.list.product-' + doc.fetch(:type).downcase),
            url: facet_item_url('TYPE', doc.fetch(:type))
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

      def facet_item_url(facet, item)
        if facet_in_params?(facet, item)
          search_action_path(remove_facet_params(facet, item, params))
        else
          search_action_path(add_facet_params_and_redirect(facet, item))
        end
      end

      def simple_facet_template_data(facet)
        capitalise_labels = true unless ['PROVIDER', 'DATA_PROVIDER'].include?(facet.name)
        {
          simple: true,
          title: facet_map(facet.name),
          select_one: (facet.name == 'CHANNEL'),
          items: facet.items.collect do |item|
            {
              url: facet_item_url(facet.name, item),
              text: facet_map(facet.name, item.value).split.map{|x| (capitalise_labels ? x.capitalize : x) }.join(' '),                
              num_results: number_with_delimiter(item.hits),
              is_checked: facet_in_params?(facet.name, item)
            }
          end
        }
      end

      def range_facet_template_data(facet)
        range_min = facet.items.collect(&:value).min
        range_max = facet.items.collect(&:value).max
        hits_max = facet.items.collect(&:hits).max
        {
          date: true,
          title: facet_map(facet.name),
          form: {
            action_url: search_action_url,
            hidden_inputs: hidden_inputs_for_search
          },
          range: {
            start: {
              input_name: "range[#{facet.name}][begin]",
              input_value: range_min,
              label_text: 'From:'
            },
            end: {
              input_name: "range[#{facet.name}][end]",
              input_value: range_max,
              label_text: 'To:'
            }
          },
          data: facet.items.sort_by(&:value).collect do |item|
            p = reset_search_params(params).deep_dup
            p[:f] ||= {}
            p[:f][facet.name] = [item.value]
            {
              percent_of_max: (item.hits.to_f / hits_max.to_f * 100).to_i,
              value: "#{item.value} (#{item.hits})",
              url: search_action_path(p)
            }
          end,
          date_start: range_min,
          date_end: range_max
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
        begin
          labels =  doc.fetch('edmConceptPrefLabelLangAware')
          if(!labels[0..3].nil?)
          {
            items: labels[0..3].map { |c| { text: c } } 
          }
          else
            []
          end
        rescue KeyError
          []
        end
      end

            
    end
  end
end
