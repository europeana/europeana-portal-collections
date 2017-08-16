# frozen_string_literal: true

module Entities
  class Show < ApplicationView
    include EntityDisplayingView
    include SearchableView

    ENTITY_SEARCH_QUERY_FIELDS = {
      agent: {
        by: %w(proxy_dc_creator proxy_dc_contributor)
      },
      concept: {
        about: 'what'
      }
    }.freeze

    def bodyclass
      'channel_entity'
    end

    def page_content_heading
      entity_title
    end

    def navigation
      {
        # TODO
        breadcrumbs: [
          {
            label: entity_title
          }
        ]
      }.merge(super)
    end

    def include_nav_searchbar
      true
    end

    def head_meta
      mustache[:head_meta] ||= begin
        title = page_title
        head_meta = [
          { meta_name: 'description', content: head_meta_description },
          { meta_property: 'fb:appid', content: '185778248173748' },
          { meta_name: 'twitter:card', content: 'summary' },
          { meta_name: 'twitter:site', content: '@EuropeanaEU' },
          { meta_property: 'og:description', content: head_meta_description },
          { meta_property: 'og:url', content: request.original_url },
          { meta_property: 'og:title', content: title }
        ]
        head_meta << { meta_property: 'og:image', content: og_image } unless og_image.nil?
        head_meta + super
      end
    end

    def head_meta_description
      mustache[:head_meta_description] ||= begin
        truncate(entity_description, length: 350, separator: ' ')
      end
    end

    def og_image
      mustache[:og_image] ||= begin
        thumbnail = entity_thumbnail
        thumbnail ? thumbnail[:src] : nil
      end
    end

    def content
      mustache[:content] ||= begin
        {
          tab_items: entity_tab_items,
          input_search: input_search,
          social_share: entity_social_share,
          entity_anagraphical: entity_anagraphical,
          entity_thumbnail: entity_thumbnail,
          entity_external_link: entity_external_link,
          entity_description: entity_description,
          entity_title: entity_name
        }.compact
      end
    end

    def entity_tab_items
      ENTITY_SEARCH_QUERY_FIELDS[api_type.to_sym].keys.map do |relation|
        entity_tab_items_one_tab(api_type, relation)
      end
    end

    def entity_tab_items_one_tab(api_type, relation)
      search_query = entity_search_query(api_type, relation)
      {
        tab_title: t("site.entities.tab_items.items_#{relation}", name: entity_name),
        url: search_path(q: search_query, format: 'json'),
        search_url: search_path(q: search_query)
      }
    end

    def entity_search_query(api_type, relation)
      fields = ENTITY_SEARCH_QUERY_FIELDS[api_type.to_sym][relation.to_sym]
      [fields].flatten.map do |field|
        %(#{field}: "http://data.europeana.eu/#{api_path}")
      end.join(' OR ')
    end

    def entity_external_link
      thumb = entity_thumbnail
      return nil if thumb.nil? || thumb[:src].nil?
      {
        text: [t('site.entities.wiki_link_text')],
        href: 'https://commons.wikimedia.org/wiki/File:' + thumb[:src].split('/').pop
      }
    end

    def build_proxy_dc(name, url, path)
      %(proxy_dc_#{name}:"#{url}/#{path}")
    end
  end
end
