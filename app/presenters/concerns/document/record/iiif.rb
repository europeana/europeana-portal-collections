# frozen_string_literal: true

module Document
  module Record
    module IIIF
      extend ActiveSupport::Concern

      included do
        # National Library of Wales
        # * test record: /portal/record/9200173/9B976C77421CE43F3BDA72EF47BCCC08AF94A238.html
        # * dataset: /portal/search?q=europeana_collectionName%3A9200173*
        manifest_iiif for: { 'europeanaCollectionName' => /\A9200173/,
                             'proxies.dcIdentifier' => /\Allgc-id:/ },
                      sub: { 'proxies.dcIdentifier' => lambda { |values|
                        values.detect { |value| value.starts_with?('llgc-id:') }.sub('llgc-id:', '')
                      } },
                      url: 'http://dams.llgc.org.uk/iiif/2.0/%{proxies.dcIdentifier}/manifest.json'

        # BNF
        # * test record: /portal/record/92099/BibliographicResource_2000081662432.html
        # * dataset: /portal/search?f%5BTYPE%5D%5B%5D=TEXT&f%5BTYPE%5D%5B%5D=IMAGE&q=DATA_PROVIDER%3A"National+Library+of+France"
        manifest_iiif for: { 'aggregations.edmDataProvider' => 'National Library of France',
                             'type' => /IMAGE|TEXT/,
                             'proxies.dcIdentifier' => %r{\Ahttp://gallica.bnf.fr/} },
                      sub: { 'proxies.dcIdentifier' => lambda { |values|
                        values.detect { |value| value.starts_with?('http://gallica.bnf.fr/') }.sub('http://gallica.bnf.fr/', '')
                      } },
                      url: 'http://gallica.bnf.fr/iiif/%{proxies.dcIdentifier}/manifest.json'

        # Generic IIIF support in EDM
        # * test record: /portal/record/07931/diglit_baer1877.html
        # * dataset: /portal/search?q=wr_dcterms_isReferencedBy%3A*&qf%5B%5D=wr_svcs_hasservice%3A*&qf%5B%5D=sv_dcterms_conformsTo%3A*iiif*
        manifest_iiif for: { 'aggregations.webResources.svcsHasService' => //,
                             'aggregations.webResources.dctermsIsReferencedBy' => // },
                      url: '%{aggregations.webResources.dctermsIsReferencedBy}',
                      sub: { 'aggregations.webResources.dctermsIsReferencedBy' => ->(value) { value.first } }

        # Generic support for individual IIIF images
        # * test record: /portal/record/2064116/Museu_ProvidedCHO_Nationalmuseum__Sweden_15897
        # * dataset: /portal/search?q=NOT%20wr_dcterms_isReferencedBy%3A*&qf%5B%5D=wr_svcs_hasservice%3A*&qf%5B%5D=sv_dcterms_conformsTo%3A*iiif*
        manifest_iiif for: { 'aggregations.webResources.svcsHasService' => // },
                      url: '%{aggregations.webResources.svcsHasService}',
                      sub: { 'aggregations.webResources.svcsHasService' => ->(value) { value.first + '/info.json' } }
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

          document_iiif_manifester[:url].dup.tap do |url|
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
