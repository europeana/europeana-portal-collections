module Document
  module Record
    module IIIF
      extend ActiveSupport::Concern

      included do
        # University of Heidelberg
        # * test record: /portal/record/07927/diglit_serradifalco1834bd2.html
        manifest_iiif for: { 'about': %r{/07927/diglit_} },
                      id: lambda { |document| document.fetch('about', '').match(%r{/07927/diglit_(.*)})[1] },
                      url: "http://digi.ub.uni-heidelberg.de/diglit/iiif/%{id}/manifest.json"

        # Bodleian library
        # * test record: /portal/record/9200175/BibliographicResource_3000004673129.html
        # * dataset: /portal/search?q=europeana_collectionName%3A9200175_Ag_EU_TEL_a1008_EU_Libraries_Bodleian
        manifest_iiif for: { 'europeanaCollectionName' => '9200175_Ag_EU_TEL_a1008_EU_Libraries_Bodleian' },
                      id: lambda { |document|
                        identifier = document.fetch('proxies.dcIdentifier', [])
                        identifier.detect { |id| id.starts_with?('http://purl.ox.ac.uk/uuid/') }.sub('http://purl.ox.ac.uk/uuid/', '')
                      },
                      url: 'http://iiif.bodleian.ox.ac.uk/iiif/manifest/%{id}.json'

        # National Library of Wales
        # * test record: /portal/record/9200173/9B976C77421CE43F3BDA72EF47BCCC08AF94A238.html
        # * dataset: /portal/search?q=europeana_collectionName%3A9200173*
        manifest_iiif for: { 'europeanaCollectionName' => /\A9200173/ },
                      id: lambda { |document|
                        identifier = document.fetch('proxies.dcIdentifier', [])
                        identifier.detect { |id| id.starts_with?('llgc-id:') }.sub('llgc-id:', '')
                      },
                      url: 'http://dams.llgc.org.uk/iiif/2.0/%{id}/manifest.json'

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

      # IIIF manifests can be derived from:
      # * some dc:identifiers
      # * on a collection basis or an individual item basis
      # * or from urls
      def iiif_manifest
        @iiif_manifest ||= begin
          unless document_iiif_manifester.nil?
            if document_iiif_manifester[:id]
              id = document_iiif_manifester[:id].call(@document) 
              document_iiif_manifester[:url].sub('%{id}', id)
            else
              document_iiif_manifester[:url]
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

      def iiif_manifest_by_identifier
        ids = {
          # test url: http://localhost:3000/portal/record/9200365/BibliographicResource_3000094705862.html
          'http://gallica.bnf.fr/ark:/12148/btv1b84539771' => 'http://iiif.biblissima.fr/manifests/ark:/12148/btv1b84539771/manifest.json',
          # test url: http://localhost:3000/portal/record/92082/BibliographicResource_1000157170184.html
          
        }

        @document.fetch('proxies.dcIdentifier', []).each do |identifier|
          return ids[identifier] if ids.key?(identifier)
        end
      end
    end
  end
end
