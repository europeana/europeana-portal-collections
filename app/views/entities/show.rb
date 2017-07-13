# frozen_string_literal: true

require 'digest'

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
      @entity[:prefLabel][:en] || 'No title'
    end

    def get_entity_name
      @entity[:prefLabel][:en] || 'No name'
    end

    def get_entity_description
      description = 'No description'
      biographicalInformation = @entity[:biographicalInformation]
      if entity_valid_hash_array?(biographicalInformation, %w{@language @value})
        item = biographicalInformation.find {|item| item['@language'] == page_locale}
        item ||= biographicalInformation[0]
        description = item['@value']
      end
      description
    end

    def get_entity_occupation
      result = ['No occupation']
      poc = @entity[:professionOrOccupation]
      if entity_valid_hash_array?(poc, ['@id'] )
        poc.map! { |p| p.key?('@id') ? p[:@id].match(/[^\/]*$/)[0] : nil }
        result = poc.select { |p| ! p.nil? }
      end
      result
    end

    def get_entity_birth_date
      @entity[:dateOfBirth][0]
    end

    def get_entity_birth_place
      get_entity_place @entity[:placeOfBirth]
    end

    def get_entity_birth
      get_entity_date_and_place(get_entity_birth_date, get_entity_birth_place)
    end

    def get_entity_death_date
      @entity[:dateOfDeath][0]
    end

    def get_entity_death_place
      get_entity_place @entity[:placeOfDeath]
    end

    def get_entity_death
      get_entity_date_and_place(get_entity_death_date, get_entity_death_place)
    end

    def get_entity_place(place)
      result = 'No place'
      if entity_valid_hash_array?(place, ['@id'] )
        place.map! { |p| p.key?('@id') ? p[:@id].match(/[^\/]*$/)[0] : nil }
        place.select! { |p| ! p.nil? }
        result = place.join(', ')
      end
      result
    end

    def get_entity_date_and_place(date, place)
      results = []
      date = date.to_s
      place = place.to_s
      results.push(date.length ? date : 'No date')
      results.push(place.length ? place : 'No place')
    end

    def get_entity_thumbnail
      d = @entity[:depiction]
      # d = 'http://commons.wikimedia.org/wiki/Special:FilePath/Tour_Eiffel_Wikimedia_Commons.jpg'
      src = 'http://junkee.com/wp-content/uploads/2014/09/fry-the-simpsons-and-futurama-set-for-crossover-in-november.jpeg'
      if d
        m = d.match(/^.*\/Special:FilePath\/(.*)$/i)
        if m
          image = m[1]
          md5 = Digest::MD5.hexdigest image
          # https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Tour_Eiffel_Wikimedia_Commons.jpg/200px-Tour_Eiffel_Wikimedia_Commons.jpg
          src = "https://upload.wikimedia.org/wikipedia/commons/thumb/#{md5[0]}/#{md5[0..1]}/#{image}/200px-#{image}"
        end
      end
      { src: src }
    end

    def entity_valid_hash_array?(arr, keys)
      return false unless arr && arr.is_a?(Array) && arr.length && arr.first.is_a?(Hash)
      keys.each do |key|
        return false unless arr.first.key? key
      end
      true
    end
  end
end

