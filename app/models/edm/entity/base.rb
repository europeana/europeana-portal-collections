
module EDM
  module Entity
    class Base
      include ActiveModel::Model

      attr_accessor :id, :locale, :m

      ENTITY_SEARCH_QUERY_FIELDS = {
        agent: {
          by: %w(proxy_dc_creator proxy_dc_contributor)
        },
        concept: {
          about: 'what'
        }
      }.freeze

      class << self
        attr_reader :human_type

        def subclass_for_human_type(human_type)
          case human_type
          when 'period'
            EDM::Entity::Timespan
          when 'person'
            EDM::Entity::Agent
          when 'place'
            EDM::Entity::Place
          when 'topic'
            EDM::Entity::Concept
          else
            fail ArgumentError, %(Human entity type unknown: "#{human_type}")
          end
        end

        protected

        def has_human_type(human_type)
          @human_type = human_type
        end
      end

      def bodyclass
        'channel_entity'
      end

      def page_content_heading
        title
      end

      def navigation
        {
          breadcrumbs: [
            {
              label: title
            }
          ]
        }
      end

      def content
        {
          tab_items: tab_items,
          input_search: input_search,
          social_share: social_share,
          entity_anagraphical: anagraphical,
          entity_thumbnail: thumbnail,
          entity_external_link: external_link,
          entity_description: description,
          entity_title: name
        }
      end

      def tab_items
        ENTITY_SEARCH_QUERY_FIELDS[api_type.to_sym].keys.map do |relation|
          entity_tab_items_one_tab(api_type, relation)
        end
      end

      def entity_tab_items_one_tab(api_type, relation)
        search_query = entity_search_query(api_type, relation)
        {
            tab_title: t("site.entities.tab_items.items_#{relation}", name: name),
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

      def external_link
        source = thumbnail_source
        return nil if source.nil?
        {
          text: [
            t('site.entities.wiki_link_text')
          ],
          href: source
        }
      end

      def build_proxy_dc(name, url, path)
        %(proxy_dc_#{name}:"#{url}/#{path}")
      end

      def anagraphical
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

      def thumbnail
        return nil unless m.key?(:depiction) &&
            m[:depiction].is_a?(Hash) &&
            m[:depiction].key?(:id)

        full = m[:depiction][:id]

        m = full.match(%r{^.*/Special:FilePath/(.*)$}i)
        return nil if m.nil?

        src = entity_build_src(m[1], 400)
        { src: src, full: full, alt: m[1] }
      end

      def thumbnail_source
        m.key?(:depiction) ? m[:depiction][:source] : nil
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

      # TODO: fallback should not be hard-coded here
      def title
        entity_pref_label('[No title]')
      end

      # TODO: fallback should not be hard-coded here
      def name
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
      def description
        raise "Need to implement description method for #{@entity.class.human_type} entity"
      end

      private

      # Returns a string
      def entity_value_by_locale(list)
        value = nil
        if list
          # Ensure that list is a valid array
          list = [list] if list.is_a?(Hash)
          if list && list.is_a?(Array) && list.length && list.first.is_a?(Hash)
            item = list.detect { |l| l['@language'] == locale } || list.detect { |l| l['@language'] == 'en' }
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
        pl = m[:prefLabel]
        if pl && pl.is_a?(Hash) && pl.present?
          localised_pl = pl[locale] || pl[:en]
          [localised_pl].flatten.first
        else
          default_label
        end
      end

      def entity_birth_date
        entity_date(m[:dateOfBirth])
      end

      def entity_birth_place
        entity_place(m[:placeOfBirth])
      end

      def entity_birth
        entity_date_and_place(entity_birth_date, entity_birth_place)
      end

      def entity_death_date
        entity_date(m[:dateOfDeath])
      end

      def entity_death_place
        entity_place m[:placeOfDeath]
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
        result = entity_value(m[:professionOrOccupation])
        if result.is_a?(String)
          result = result.split(',')
        elsif result.is_a?(Array)
          result = format_entity_resource_urls(result)
        end
        result
      end
    end
  end
end
