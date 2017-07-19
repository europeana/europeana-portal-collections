# frozen_string_literal: true
##
# For views needing to display entities
module EntityDisplayingView
  extend ActiveSupport::Concern

  protected

  def entity_head_meta
    mustache[:entity_head_meta] ||= begin
      [
        { meta_property: 'fb:appid', content: '185778248173748' },
        { meta_name: 'twitter:card', content: 'summary' },
        { meta_name: 'twitter:site', content: '@EuropeanaEU' },
        { meta_property: 'og:url', content: request.original_url }
      ]
    end
  end

  def entity_anagraphical
    result = [
      {
        label: t('site.entities.anagraphic.birth'),
        value: entity_birth
      },
      {
        label: t('site.entities.anagraphic.death'),
        value: entity_death
      },
      {
        label: t('site.entities.anagraphic.occupation'),
        value: entity_occupation
      }
    ].reject { |item| item[:value].nil? }

    result.size.zero? ? nil : result
  end

  def entity_thumbnail
    result = nil
    full = @entity[:depiction]
    if full
      m = full.match(%r{^.*\/Special:FilePath\/(.*)$}i)
      if m
        src = entity_build_src(m[1], 400)
        result = { src: src, full: full, alt: m[1] }
      end
    end
    result
  end

  def entity_social_share
    {
      url: 'this page url for share links',
      twitter: true,
      facebook: true,
      pinterest: true,
      googleplus: true,
      tumblr: true
    }
  end

  def entity_params
    @entity[:__params__] || {}
  end

  def entity_title
    entity_pref_label('[No title]')
  end

  def entity_name
    entity_pref_label('[No name]')
  end

  # biographicalInformation: [
  #   {
  #     @language: "en",
  #     @value: "..."
  #   },
  #   ...
  # ]
  #
  # Returns a string
  def entity_description
    entity_value_by_locale(@entity[:biographicalInformation])
  end

  # TODO
  def entity_external_link
    {
      text: [
        'Topmost text goes here',
        'Remaining text goes here and is a little bit longer'
      ],
      href: 'javscript:alert("Go to the external page")'
    }
  end

  private

  # Returns a string
  def entity_value_by_locale(list)
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
  def entity_values_by_id(list)
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
  def entity_value(list)
    entity_value_by_locale(list) || entity_values_by_id(list) || nil
  end

  # Returns a string
  def entity_place(place)
    result = entity_value(place)
    if result.is_a?(String)
      result = capitalize_words(result.strip)
    elsif result.is_a?(Array)
      result = format_entity_resource_urls(result)
      result = capitalize_words(result.join(', '))
    end
    result
  end

  def entity_date_and_place(date, place)
    result = [date, place].reject(&:nil?)
    result.size.zero? ? nil : result
  end

  # The logic for going from: http://commons.wikimedia.org/wiki/Special:FilePath/[image] to
  # https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/[image]/200px-[image] is the following:
  #
  # The first part is always the same: https://upload.wikimedia.org/wikipedia/commons/thumb
  # The second part is the first character of the MD5 hash of the file name. In this case, the MD5 hash
  # of Tour_Eiffel_Wikimedia_Commons.jpg is a85d416ee427dfaee44b9248229a9cdd, so we get /a.
  # The third part is the first two characters of the MD5 hash from above: /a8.
  # The fourth part is the file name: /[image]
  # The last part is the desired thumbnail width, and the file name again: /200px-[image]
  #
  # Returns a string
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
  # Returns an array of strings
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
      map { |s| capitalize_words(s) }
  end

  def entity_pref_label(default_label)
    pl = @entity[:prefLabel]
    pl && pl.is_a?(Hash) && pl.size ? pl[page_locale] || pl[:en] : default_label
  end

  def entity_birth_date
    entity_date(@entity[:dateOfBirth])
  end

  def entity_birth_place
    entity_place(@entity[:placeOfBirth])
  end

  def entity_birth
    entity_date_and_place(entity_birth_date, entity_birth_place)
  end

  def entity_death_date
    entity_date(@entity[:dateOfDeath])
  end

  def entity_death_place
    entity_place @entity[:placeOfDeath]
  end

  def entity_death
    entity_date_and_place(entity_death_date, entity_death_place)
  end

  def entity_date(date)
    # Just grab the first date in the array if present.
    date && date.is_a?(Array) && date.length && date.first.is_a?(String) ? date.first : nil
  end

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
  #   ...
  # }
  #
  # Returns an array of strings
  def entity_occupation
    result = entity_value(@entity[:professionOrOccupation])
    if result.is_a?(String)
      result = capitalize_words(result)
      result = result.split(',').map(&:strip)
    elsif result.is_a?(Array)
      result = format_entity_resource_urls(result)
    end
    result
  end
end
