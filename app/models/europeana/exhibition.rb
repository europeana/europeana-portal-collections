# frozen_string_literal: true

module Europeana
  # Represents (but does not store) a Europeana Exhibition.
  #
  # @see https://github.com/europeana/europeana-virtual-exhibitions
  class Exhibition
    include ActiveModel::Model

    # Regexp to match Europeana Exjibition urls
    URL_PATTERN = %r|https?://.+/portal/[a-z]{2}/exhibitions/.+|

    # @return [String] Europeana ID of this record
    attr_accessor :credit_image, :description, :card_image, :lang_code, :tags, :title, :slug, :url

    class << self
      # Does the argument look like a Europeana exhibition url?
      #
      # @param candidate [String] String to test
      # @return [Boolean]
      def exhibition?(candidate)
        !!(candidate =~ /\A#{URL_PATTERN}\z/)
      end

      def find(url)
        return [] unless exhibition?(url)
        # json_response = JSON.load(open(url + '.json'))
        # TODO get exhibition as json once exhibitions supports it.
        # just fake it for now
        json_response = JSON.parse('{
            "url":"' + url + '",
            "credit_image":"https://europeana-exhibitions-production.cdnedge.bluemix.net/images/versions/f4f67f17f93a9a7b06c5762fabf6c8d72809496f/Finnish_National_Gallery_logo.jpeg",
            "description":"Throughout the modern era, European artists have ventured abroad to study and work, seeking new inspiration and experiences. Their travels have often taken them beyond Europe’s borders, into diverse cultures and communities. Drawing on the rich collection of the Finnish National Gallery and other archival sources, this exhibition traces the journeys of Finnish artists from the 1880s to the 1930s, across north Africa and the Middle East to New York and New Mexico.",
            "card_image":"https://europeana-exhibitions-production.cdnedge.bluemix.net/images/versions/dd3ad27fdaf4889f02a3f18265c79d51e4d5040c/Exhibition_hero_image.jpeg",
            "lang_code":"en",
            "title":"An Ecstasy of Beauty",
            "slug":"/an-ecstasy-of-beauty"
             }')
        new(json_response)
      end
    end

    # @see Europeana::Record.portal_url
    def portal_url
      self.class.portal_url(id)
    end
  end
end
