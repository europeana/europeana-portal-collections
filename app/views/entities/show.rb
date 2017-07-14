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
      get_entity_title
    end

    def include_nav_searchbar
      true
    end

    # # TODO
    # def head_meta
    #   mustache[:head_meta] ||= begin
    #     head_meta = entity_head_meta + [
    #       { meta_name: 'description', content: get_entity_description },
    #       { meta_property: 'og:description', content: get_entity_description },
    #       { meta_property: 'og:image', content: get_entity_image_url },
    #       { meta_property: 'og:title', content: get_entity_title },
    #       { meta_property: 'og:sitename', content: get_entity_title }
    #     ]
    #     head_meta + super
    #   end
    # end

    def content
      params = get_entity_params
      mustache[:content] ||= begin
        {
          tab_items: [
            {
              tab_title: "Items by #{get_entity_name}",
              url: entities_fetch_items_by_path(params[:type], params[:namespace], params[:identifier])
            },
            {
              tab_title: "Items about #{get_entity_name}",
              url: entities_fetch_items_about_path(params[:type], params[:namespace], params[:identifier])
            }
          ],
          input_search: input_search,
          social_share: {
            url: 'this page url for share links',
            twitter: true,
            facebook: true,
            pinterest: true,
            googleplus: true,
            tumblr: true
          },
          entity_anagraphical: [
            {
              label: 'Birth',
              # label: t('site.entity.anagraphic.birth'),
              value: get_entity_birth
            },
            {
              label: 'Death',
              # label: t('site.entity.anagraphic.death'),
              value: get_entity_death
            },
            {
              label: 'Occupation',
              # label: t('site.entity.anagraphic.occupation'),
              value: get_entity_occupation
            }
          ],
          entity_title: get_entity_name,
          entity_thumbnail: get_entity_thumbnail,
          entity_description: get_entity_description
        }
      end
    end

    private

    def get_entity_params
      @entity[:__params__] || {}
    end

    def get_entity_title
      get_entity_pref_label('[No title]')
    end

    def get_entity_name
      get_entity_pref_label('[No name]')
    end

    def get_entity_pref_label(default_label)
      pl = @entity[:prefLabel]
      pl && pl.is_a?(Hash) && pl.size ? pl[page_locale] || pl[:en] : default_label
    end

    # biographicalInformation: [
    #   {
    #     @language: "en",
    #     @value: "..."
    #   },
    #   ...
    # ]
    def get_entity_description
      get_entity_property_by_language(@entity[:biographicalInformation]) || '[No description]'
    end

    def get_entity_property_by_language(list)
      return nil unless list
      result = nil
      # Ensure that list is a valid array
      list = [list] if list.is_a?(Hash)
      if list && list.is_a?(Array) && list.length && list.first.is_a?(Hash)
        item = list.detect { |l| l['@language'] == page_locale } || list.detect { |l| l['@language'] == 'en' }
        result = item['@value'] if item && item.key?('@value')
      end
      result
    end

    #
    # For multiple items the format is just an array of hash items
    #
    # professionOrOccupation: [
    #   {
    #     @id: "http://dbpedia.org/resource/Pianist",
    #   },
    #   -or-
    #   {
    #     @language: "en",
    #     @value: "occupation1, occupation2, ..."
    #   },
    #   ...
    # ]
    #
    # where for single items the format is just a hash
    #
    # professionOrOccupation:{
    # }
    # Returns array
    def get_entity_occupation
      list = @entity[:professionOrOccupation]
      result = get_entity_property_by_language(list)
      if result
        result = result.split(',').map(&:strip).map(&:capitalize)
      elsif list
        list = [list] if list.is_a?(Hash)
        list.map! { |l| l.key?('@id') ? l[:@id].match(%r{[^\/]+$})[0] : nil }
        result = list.reject(&:nil?).map(&:capitalize).map{ |s| URI.unescape(s) }.map{ |s| s.tr('_', ' ') }
      end
      result || ['[No occupation]']
    end

    def get_entity_birth_date
      get_entity_date(@entity[:dateOfBirth])
    end

    def get_entity_birth_place
      get_entity_place(@entity[:placeOfBirth])
    end

    def get_entity_birth
      get_entity_date_and_place(get_entity_birth_date, get_entity_birth_place)
    end

    def get_entity_death_date
      get_entity_date(@entity[:dateOfDeath])
    end

    def get_entity_death_place
      get_entity_place @entity[:placeOfDeath]
    end

    def get_entity_death
      get_entity_date_and_place(get_entity_death_date, get_entity_death_place)
    end

    def get_entity_date(date)
      # Just grab the first date in the array if present.
      date && date.is_a?(Array) && date.length && date.first.is_a?(String) ? date.first : '[No date]'
    end

    def get_entity_place(place)
      result = '[No place]'
      list = place
      list = [list] if list.is_a?(Hash)
      if list && list.is_a?(Array) && list.length && list.first.is_a?(Hash)
        item = list.detect { |l| l['@language'] == page_locale } || list.detect { |l| l['@language'] == 'en' }
        if item && item.key?('@value')
          result = item['@value'].capitalize
        else
          list.map! { |l| l.key?('@id') ? l[:@id].match(%r{[^\/]+$})[0] : nil }
          result = list.reject(&:nil?).join(', ')
        end
      end
      result
    end

    def get_entity_date_and_place(date, place)
      [date, place]
    end

    def get_entity_thumbnail
      full = @entity[:depiction]
      src = 'http://junkee.com/wp-content/uploads/2014/09/fry-the-simpsons-and-futurama-set-for-crossover-in-november.jpeg'
      if full
        m = full.match(%r{^.*\/Special:FilePath\/(.*)$}i)
        if m
          src = entity_build_src(m[1], 400)
        end
      end
      { src: src, full: full, alt: 'thumbnail alt text here' }
    end

    def entity_build_src(image, size)
      md5 = Digest::MD5.hexdigest image
      "https://upload.wikimedia.org/wikipedia/commons/thumb/#{md5[0]}/#{md5[0..1]}/#{image}/#{size}px-#{image}"
    end
  end
end
