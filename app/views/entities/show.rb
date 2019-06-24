# frozen_string_literal: true

module Entities
  class Show < ApplicationView
    include SearchableView

    def bodyclass
      'channel_entity'
    end

    def page_content_heading
      @entity.pref_label
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
        head_meta << { meta_property: 'robots', content: 'noindex' } if unreferenced?
        head_meta + super
      end
    end

    def head_meta_description
      mustache[:head_meta_description] ||= begin
        truncate(@entity.description, length: 350, separator: ' ')
      end
    end

    def og_image
      return mustache[:og_image] if mustache.key?(:og_image)
      mustache[:og_image] = thumbnail.present? ? thumbnail[:src] : nil
    end

    def navigation
      {
        breadcrumbs: [
          {
            label: @entity.pref_label
          }
        ]
      }.merge(super)
    end

    def content
      mustache[:content] ||= begin
        {
          tab_items: tab_items,
          entity_anagraphical: anagraphical,
          entity_thumbnail: thumbnail,
          entity_external_link: external_link,
          entity_description: @entity.description,
          entity_title: @entity.pref_label,
          input_search: input_search,
          social_share: social_share
        }
      end
    end

    ##
    # Translated label for the entity description, e.g. "Biography" for agents
    #
    # @return [String]
    def entity_description_title
      i18n_key = @entity.class.human_type == 'person' ? 'bio' : 'description'
      t(i18n_key, scope: 'site.entities.labels')
    end

    protected

    def thumbnail
      return mustache[:thumbnail] if mustache.key?(:thumbnail)

      mustache[:thumbnail] = begin
        if @entity.has_depiction? && @entity.thumbnail_filename.present?
          { src: @entity.thumbnail_src, full: @entity.thumbnail_full, alt: @entity.thumbnail_filename }
        end
      end
    end

    def unreferenced?
      !referenced_records.detect { |_key, records| records[:total][:value] != 0 }
    end

    def referenced_records
      @referenced_records ||= begin
        @entity.search_keys.each_with_object({}) do |key, memo|
          memo[key] ||= begin
            if @entity.respond_to?(:search_query)
              response = @search_keys_search_results[key]
              {
                search_results: response.documents.map { |doc| document_presenter(doc, response).content },
                total: {
                  value: response.total,
                  formatted: number_with_delimiter(response.total)
                }
              }
            else
              { search_results: [], total: { value: 0, formatted: '0' } }
            end
          end
        end
      end
    end

    def document_presenter(doc, response)
      Document::BlacklightSearchResultPresenter.new(doc, self, response)
    end

    def tab_items
      tabs.map do |key|
        {
          tab_title: t(key, scope: 'site.entities.tab_items', name: @entity.pref_label),
          url: search_path(q: @entity.search_query(key), format: 'json'),
          search_url: search_path(q: @entity.search_query(key)),
          referenced_records: referenced_records[key]
        }
      end
    end

    def tabs
      @entity.search_keys
    end

    def social_share
      {
        url: CGI.escape(request.original_url),
        twitter: true,
        facebook: true,
        pinterest: true,
        tumblr: true
      }
    end

    def anagraphical
      return nil unless @entity.is_a?(EDM::Entity::Agent)

      result = [
        {
          label: t('site.entities.anagraphic.birth'),
          value: @entity.birth
        },
        {
          label: t('site.entities.anagraphic.death'),
          value: @entity.death
        },
        {
          label: t('site.entities.anagraphic.occupation'),
          value: @entity.occupation
        }
      ].reject { |item| item[:value].nil? }

      result.blank? ? nil : result
    end

    def external_link
      return nil if @entity.depiction_source.nil?
      {
        text: [
          t('site.entities.wiki_link_text')
        ],
        href: @entity.depiction_source
      }
    end
  end
end
