# frozen_string_literal: true

module Entities
  class Show < ApplicationView
    include SearchableView

    def bodyclass
      @entity.bodyclass
    end

    def page_content_heading
      @entity.page_content_heading
    end

    def navigation
      @entity.navigation.merge(super)
    end

    def include_nav_searchbar
      true
    end

    def head_meta
      mustache[:head_meta] ||= begin
        head_meta = [
          { meta_name: 'description', content: head_meta_description },
          { meta_property: 'fb:appid', content: '185778248173748' },
          { meta_name: 'twitter:card', content: 'summary' },
          { meta_name: 'twitter:site', content: '@EuropeanaEU' },
          { meta_property: 'og:description', content: head_meta_description },
          { meta_property: 'og:url', content: request.original_url },
          { meta_property: 'og:title', content: page_title }
        ]
        head_meta << { meta_property: 'og:image', content: og_image } unless og_image.nil?
        head_meta + super
      end
    end

    def head_meta_description
      mustache[:head_meta_description] ||= begin
        truncate(@entity.description, length: 350, separator: ' ')
      end
    end

    def og_image
      mustache[:og_image] ||= begin
        tn = @entity.thumbnail
        tn ? tn[:src] : nil
      end
    end

    def bodyclass
      'channel_entity'
    end

    def page_content_heading
      @entity.title
    end

    def navigation
      {
        breadcrumbs: [
          {
            label: @entity.title
          }
        ]
      }
    end

    def content
      mustache[:content] ||= begin
        {
          tab_items: tab_items,
          entity_anagraphical: @entity.anagraphical,
          entity_thumbnail: @entity.thumbnail,
          entity_external_link: @entity.external_link,
          entity_description: @entity.description,
          entity_title: @entity.name,
          input_search: input_search,
          social_share: social_share
        }
      end
    end

    def tab_items
      @entity.tabs.map do |key, search_url|
        {
          tab_title: t("site.entities.tab_items.#{key.to_s}", name: @entity.name),
          url: search_url + '&format=json',
          search_url: search_url
        }
      end
    end

    def social_share
      {
        url: request.original_url,
        twitter: true,
        facebook: true,
        pinterest: true,
        googleplus: true,
        tumblr: true
      }
    end
  end
end
