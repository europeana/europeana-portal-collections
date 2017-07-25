# frozen_string_literal: true

require 'digest'
require 'uri'

module Entities
  class Show < ApplicationView
    include EntityDisplayingView
    include SearchableView

    def bodyclass
      'channel_entity'
    end

    def page_content_heading
      entity_title
    end

    def navigation
      {
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

    # TODO
    # def head_meta
    #   mustache[:head_meta] ||= begin
    #     title = page_title
    #     head_meta = [
    #       { meta_name: 'description', content: head_meta_description },
    #       { meta_property: 'fb:appid', content: '185778248173748' },
    #       { meta_name: 'twitter:card', content: 'summary' },
    #       { meta_name: 'twitter:site', content: '@EuropeanaEU' },
    #       { meta_property: 'og:sitename', content: title },
    #       { meta_property: 'og:description', content: head_meta_description },
    #       { meta_property: 'og:url', content: collection_url(@collection.key) }
    #     ]
    #     head_meta << { meta_property: 'og:title', content: title } unless title.nil?
    #     head_meta << { meta_property: 'og:image', content: @landing_page.og_image } unless @landing_page.og_image.blank?
    #     head_meta + super
    #   end
    # end

    def content
      mustache[:content] ||= begin
        {
          tab_items: [
            {
              tab_title: t('site.entities.tab_items.items_by', name: entity_name),
              url: search_path(q: @items_by_query, format: 'json'),
              search_url: search_path(q: @items_by_query)
            },
            {
              # TODO
              tab_title: t('site.entities.tab_items.items_about', name: entity_name),
            }
          ],
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

    def entity_external_link
      thumb = entity_thumbnail
      return nil if thumb.nil? || thumb[:src].nil?
      {
        text: [
          t('site.entities.wiki_link_text')
        ],
        href: 'https://commons.wikimedia.org/wiki/File:' + thumb[:src].split('/').pop
      }
    end

  end
end
