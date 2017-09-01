# frozen_string_literal: true

##
# For views needing to display entities
module EntityDisplayingView
  extend ActiveSupport::Concern

  def entity_anagraphical
    return nil unless api_type == 'agent'
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
    return nil unless @entity.key?(:depiction) &&
                      @entity[:depiction].is_a?(Hash) &&
                      @entity[:depiction].key?(:id)

    full = @entity[:depiction][:id]

    m = full.match(%r{^.*/Special:FilePath/(.*)$}i)
    return nil if m.nil?

    src = entity_build_src(m[1], 400)
    { src: src, full: full, alt: m[1] }
  end

  def entity_thumbnail_source
    @entity.key?(:depiction) ? @entity[:depiction][:source] : nil
  end

  def entity_social_share
    {
      url: request.original_url,
      twitter: true,
      facebook: true,
      pinterest: true,
      googleplus: true,
      tumblr: true
    }
  end

  # TODO: fallback should not be hard-coded here
  def entity_title
    entity_pref_label('[No title]')
  end

  # TODO: fallback should not be hard-coded here
  def entity_name
    entity_pref_label('[No name]')
  end

  # agent => biographicalInformation: [
  #   {
  #     @language: "en",
  #     @value: "..."
  #   },
  #   ...
  # ]
  #
  # concept => note: {
  #   en: ["..."],
  # }
  #
  # Returns a string
  def entity_description
    api_type == 'agent' ? entity_value_by_locale(@entity[:biographicalInformation]) : entity_note(@entity[:note])
  end

  ##
  # Translated label for the entity description, e.g. "Biography" for agents
  #
  # @return [String]
  def entity_description_title
    i18n_key = api_type == 'agent' ? 'bio' : 'description'
    t(i18n_key, scope: 'site.entities.labels')
  end

  private

  # Returns a string: locale, english or nil
  def entity_note(note)
    return nil unless note.present? && note.is_a?(Hash)
    if note.key?(page_locale.to_sym)
      note[page_locale.to_sym].first
    elsif note.key?(:en)
      note[:en].first
    end
  end

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
    if result.is_a?(Array)
      result = format_entity_resource_urls(result)
      result = result.join(', ')
    end
    result
  end

  def entity_date_and_place(date, place)
    result = [date, place].compact
    result.size.zero? ? nil : result
  end

  # The logic for going from: http://commons.wikimedia.org/wiki/Special:FilePath/[image] to
  # https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/[image]/200px-[image] is the following:
  #
  # The first part is always the same: https://upload.wikimedia.org/wikipedia/commons/thumb
  # The second part is the first character of the MD5 hash of the file name. In this case, the MD5 hash
  # of Tour_Eiffel_Wikimedia_Commons.jpg is a85d416ee427dfaee44b9248229a9cdd, so we get /a.
  # NB: File names will first have space characters " " replaced with underscores "_".
  # The third part is the first two characters of the MD5 hash from above: /a8.
  # The fourth part is the file name: /[image]
  # The last part is the desired thumbnail width, and the file name again: /200px-[image]
  #
  # @param image [String] the image file name extracted from the URL path
  # @param size [Fixnum] size of the image required
  # @return [String]
  # @see https://meta.wikimedia.org/wiki/Thumbnails#Dynamic_image_resizing_via_URL
  def entity_build_src(image, size)
    underscored_image = URI.unescape(image).tr(' ', '_')
    md5 = Digest::MD5.hexdigest(underscored_image)
    "https://upload.wikimedia.org/wikipedia/commons/thumb/#{md5[0]}/#{md5[0..1]}/#{underscored_image}/#{size}px-#{underscored_image}"
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
      map { |s| s.sub(/^_/, '') }.
      map { |s| s.sub(/_$/, '') }.
      map { |s| s.tr('_', ' ') }
  end

  # @param default_label [String] fallback if no localised prefLabel available
  # @return [String] localised prefLabel or fallback
  def entity_pref_label(default_label)
    pl = @entity[:prefLabel]
    if pl && pl.is_a?(Hash) && pl.present?
      localised_pl = pl[page_locale] || pl[:en]
      [localised_pl].flatten.first
    else
      default_label
    end
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

  def entity_date(dates)
    return nil unless dates.present?
    (date_most_accurate(dates) || dates.first).strip
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
      result = result.split(',')
    elsif result.is_a?(Array)
      result = format_entity_resource_urls(result)
    end
    result
  end
end
