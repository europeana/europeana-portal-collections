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
      get_entity_value_by_locale(@entity[:biographicalInformation]) || '[No description]'
    end

    # Returns a single string
    def get_entity_value_by_locale(list)
      value = nil
      if list
        # Ensure that list is a valid array
        list = [list] if list.is_a?(Hash)
        if list && list.is_a?(Array) && list.length && list.first.is_a?(Hash)
          item = list.detect { |l| l['@language'] == page_locale } || list.detect { |l| l['@language'] == 'en' }
          value = item['@value'] if item && item.key?('@value')
        end
      end
      value
    end

    # Returns an array of strings
    def get_entity_values_by_id(list)
      values = nil
      if list
        # Ensure that list is a valid array
        list = [list] if list.is_a?(Hash)
        if list && list.is_a?(Array) && list.length && list.first.is_a?(Hash)
          values = list.map { |l| l['@id'] }
          values.reject!(&:nil?)
        end
      end
      values
    end

    # Returns either a string or an array of strings, depending on whether
    # a single @language value has been found or a list of @ids.
    def get_entity_value(list)
      get_entity_value_by_locale(list) || get_entity_values_by_id(list)
    end

    #
    # For multiple items the format is just an array of hash items
    #
    # professionOrOccupation: [
    #   {
    #     @id: "http://dbpedia.org/resource/Pianist",
    #   },
    #   -and/or-
    #   {
    #     @language: "en",
    #     @value: "occupation1, occupation2, ..."
    #   },
    #   ...
    # ]
    #
    # where for single items we can remove the brackets and the format is
    # just a hash:
    #
    # professionOrOccupation:{
    # }
    #
    # Returns array
    def get_entity_occupation
      result = get_entity_value(@entity[:professionOrOccupation])
      if result.is_a?(String)
        result = result.split(',').map(&:strip).map(&:capitalize)
      elsif result.is_a?(Array)
        result = format_entity_resource_urls(result)
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

    # Returns a string
    def get_entity_place(place)
      result = get_entity_value(place)
      if result.is_a?(String)
        result = result.strip.capitalize
      elsif result.is_a?(Array)
        result = format_entity_resource_urls(result)
        result = result.join(', ')
      end
      result || '[No place]'
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

    # The logic for going from: http://commons.wikimedia.org/wiki/Special:FilePath/[image] to https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/[image]/200px-[image] is the following:
    #
    # The first part is always the same: https://upload.wikimedia.org/wikipedia/commons/thumb
    # The second part is the first character of the MD5 hash of the file name. In this case, the MD5 hash of Tour_Eiffel_Wikimedia_Commons.jpg is a85d416ee427dfaee44b9248229a9cdd, so we get /a.
    # The third part is the first two characters of the MD5 hash from above: /a8.
    # The fourth part is the file name: /[image]
    # The last part is the desired thumbnail width, and the file name again: /200px-[image]
    #
    def entity_build_src(image, size)
      md5 = Digest::MD5.hexdigest image
      "https://upload.wikimedia.org/wikipedia/commons/thumb/#{md5[0]}/#{md5[0..1]}/#{image}/#{size}px-#{image}"
    end

    # Takes an array of results of the form:
    #
    # [ "http://dbpedia.org/resource/_Pianist",
    #   "http://dbpedia.org/resource/opera_singer",
    #   "Some junk",
    #   "http://dbpedia.org/resource/Composer" ]
    #
    # to:
    #
    # [ "Pianist",
    #   "Opera singer",
    #   "Composer" ]
    #
    def format_entity_resource_urls(results)
      results.
        map { |l| l.match(%r{[^\/]+$}) }.
        reject(&:nil?).
        map { |s| s[0] }.
        map { |s| URI.unescape(s) }.
        map(&:strip).
        map { |s| s.sub(/^_/, '') }.
        map { |s| s.sub(/_$/, '') }.
        map { |s| s.tr('_', ' ') }.
        map(&:capitalize)
    end
  end
end
