module Document
  module Record
    module IIIF
      extend ActiveSupport::Concern

      included do
        # University of Heidelberg
        # * test record: /portal/record/07927/diglit_serradifalco1834bd2.html
        manifest_iiif for: { 'about': %r{/07927/diglit_} },
                      sub: { 'about' => lambda { |value|
                        value.match(%r{/07927/diglit_(.*)})[1]
                      } },
                      url: 'http://digi.ub.uni-heidelberg.de/diglit/iiif/%{about}/manifest.json'

        # Bodleian library
        # * test record: /portal/record/9200175/BibliographicResource_3000004673129.html
        # * dataset: /portal/search?q=europeana_collectionName%3A9200175_Ag_EU_TEL_a1008_EU_Libraries_Bodleian
        manifest_iiif for: { 'europeanaCollectionName' => '9200175_Ag_EU_TEL_a1008_EU_Libraries_Bodleian' },
                      sub: { 'proxies.dcIdentifier' => lambda { |values|
                        values.detect { |value| value.starts_with?('http://purl.ox.ac.uk/uuid/') }.sub('http://purl.ox.ac.uk/uuid/', '')
                      } },
                      url: 'http://iiif.bodleian.ox.ac.uk/iiif/manifest/%{proxies.dcIdentifier}.json'

        # National Library of Wales
        # * test record: /portal/record/9200173/9B976C77421CE43F3BDA72EF47BCCC08AF94A238.html
        # * dataset: /portal/search?q=europeana_collectionName%3A9200173*
        manifest_iiif for: { 'europeanaCollectionName' => /\A9200173/ },
                      sub: { 'proxies.dcIdentifier' => lambda { |values|
                        values.detect { |value| value.starts_with?('llgc-id:') }.sub('llgc-id:', '')
                      } },
                      url: 'http://dams.llgc.org.uk/iiif/2.0/%{proxies.dcIdentifier}/manifest.json'

        # BNF
        # * test record: /portal/record/92099/BibliographicResource_2000081662432.html
        # * dataset: /portal/search?f%5BTYPE%5D%5B%5D=TEXT&f%5BTYPE%5D%5B%5D=IMAGE&q=DATA_PROVIDER%3A"National+Library+of+France"
        manifest_iiif for: { 'aggregations.edmDataProvider' => 'National Library of France',
                             'type' => /IMAGE|TEXT/ },
                      sub: { 'proxies.dcIdentifier' => lambda { |values|
                        values.detect { |value| value.starts_with?('http://gallica.bnf.fr/') }.sub('http://gallica.bnf.fr/', '')
                      } },
                      url: 'http://gallica.bnf.fr/iiif/%{proxies.dcIdentifier}/manifest.json'

        # /portal/record/9200365/BibliographicResource_3000094705862.html
        manifest_iiif for: { 'proxies.dcIdentifier' => 'http://gallica.bnf.fr/ark:/12148/btv1b84539771' },
                      url: 'http://iiif.biblissima.fr/manifests/ark:/12148/btv1b84539771/manifest.json'

        # /portal/record/9200365/BibliographicResource_3000094948479.html
        manifest_iiif for: { 'proxies.dcIdentifier' => 'http://gallica.bnf.fr/ark:/12148/btv1b10500687r' },
                      url: 'http://iiif.biblissima.fr/manifests/ark:/12148/btv1b10500687r/manifest.json'
      end

      class_methods do
        def iiif_manifesters
          @iiif_manifesters ||= []
        end

        def manifest_iiif(manifester)
          iiif_manifesters << manifester
        end
      end

      def iiif_manifest
        @iiif_manifest ||= begin
          return if document_iiif_manifester.nil?

          document_iiif_manifester[:url].tap do |url|
            (document_iiif_manifester[:sub] || {}).each_pair do |field, proc|
              value = @document.fetch(field, nil)
              sub = proc.call(value)
              url.sub!("%{#{field}}", sub)
            end
          end
        end
      end

      protected

      def document_iiif_manifester
        @document_iiif_manifester ||= begin
          self.class.iiif_manifesters.detect do |candidate|
            candidate[:for].all? do |field, test|
              [@document.fetch(field, [])].flatten.any? do |value|
                test.is_a?(Regexp) ? (value =~ test) : (value == test)
              end
            end
          end
        end
      end
    end
  end
end
