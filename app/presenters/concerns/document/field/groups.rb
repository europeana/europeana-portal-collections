# frozen_string_literal: true
module Document
  module Field
    ##
    # Definitions of document field groups
    module Groups
      class << self
        include Document::Field::Labelling

        def concepts
          {
            title: 'concepts',
            sections: [
              {
                title: 'type',
                fields: ['proxies.dcType'],
                collected: lambda do |document|
                  document.proxies.map do |proxy|
                    proxy.fetch('dcType', nil)
                  end.flatten.compact
                end,
                search_field: 'what',
                quoted: true
              },
              {
                title: 'subject',
                search_field: 'what',
                quoted: true,
                collected: lambda do |document|
                  document.proxies.map do |proxy|
                    proxy.fetch('dcSubject', nil)
                  end.flatten.compact
                end
              },
              {
                title: 'has-type',
                search_field: 'what',
                fields: ['proxies.edmHasType']
              },
              {
                title: 'medium',
                search_field: 'proxy_dcterms_medium',
                quoted: true,
                fields: 'proxies.dctermsMedium'
              }
            ]
          }
        end

        def copyright
          {
            title: 'copyright',
            sections: [
              {
                title: 'rights',
                fields: %w(proxies.dcRights aggregations.edmRights),
                ga_data: 'dimension5'
              }
            ]
          }
        end

        def time
          {
            title: 'time',
            sections: [
              {
                title: 'date',
                fields: ['proxies.dcDate']
              },
              {
                title: 'creation-date',
                fields: ['proxies.dctermsIssued'],
                collected: lambda do |document|
                  document.proxies.map do |proxy|
                    proxy.fetch('dctermsCreated', nil)
                  end.flatten.compact.join(', ')
                end
              },
              {
                title: 'period',
                fields: ['timespans.prefLabel']
              },
              {
                title: 'publication-date',
                fields: ['proxies.dctermsPublished']
              },
              {
                title: 'issued',
                fields: ['proxies.dctermsIssued']
              },
              {
                title: 'temporal',
                fields: ['proxies.dctermsTemporal']
              },
              {
                title: 'place-time',
                fields: ['proxies.dcCoverage']
              }
            ]
          }
        end

        def description
          {
            title: 'description',
            sections: [
              {
                title: false,
                collected: ->(document) { document.fetch('proxies.dctermsTOC', nil) }
              },
              {
                title: false,
                collected: lambda do |document|
                  document.fetch('proxies.dcDescription', []).map { |val| CGI.unescapeHTML(val) }
                end
              }
            ]
          }
        end

        def location
          {
            title: 'location',
            sections: [
              {
                title: 'location',
                fields: ['proxies.dctermsSpatial'],
                collected: ->(document) { pref_label(document, 'places.prefLabel') }
              },
              {
                title: 'place-time',
                fields: ['proxies.dcCoverage']
              },
              {
                title: 'current-location',
                fields: ['proxies.edmCurrentLocation']
              }
            ]
          }
        end

        def people
          {
            title: 'people',
            sections: [
              {
                title: 'creator',
                entity_name: 'agents',
                entity_proxy_field: 'dcCreator',
                entity_extra: [
                  {
                    field: 'rdaGr2DateOfBirth',
                    map_to: 'life.from.short',
                    format_date: '%Y-%m-%d'
                  },
                  {
                    field: 'rdaGr2DateOfDeath',
                    map_to: 'life.to.short',
                    format_date: '%Y-%m-%d'
                  }
                ],
                search_field: 'who',
                fields_then_fallback: true,
                collected: ->(document) { document.fetch('proxies.dcCreator', nil) }
              },
              {
                title: 'contributor',
                entity_name: 'agents',
                entity_proxy_field: 'dcContributor',
                entity_extra: [
                  {
                    field: 'rdaGr2DateOfBirth',
                    map_to: 'life.from.short',
                    format_date: '%Y-%m-%d'
                  },
                  {
                    field: 'rdaGr2DateOfDeath',
                    map_to: 'life.to.short',
                    format_date: '%Y-%m-%d'
                  }
                ],
                search_field: 'who',
                fields_then_fallback: true,
                collected: ->(document) { document.fetch('proxies.dcContributor', nil) }
              },
              {
                title: 'subject',
                entity_name: 'agents',
                entity_proxy_field: 'dcSubject',
                search_field: 'who'
              },
              {
                title: 'publisher',
                entity_name: 'agents',
                entity_proxy_field: 'dcPublisher',
                search_field: 'who'
              },
              {
                title: 'rights',
                entity_name: 'agents',
                entity_proxy_field: 'dcRights',
                search_field: 'who'
              }
            ]
          }
        end

        def provenance
          {
            title: 'provenance',
            sections: [
              {
                title: 'source',
                collected: lambda do |document|
                  document.aggregations.map do |aggregation|
                    if aggregation.fetch('edmUgc', nil) == 'true'
                      t('site.object.meta-label.ugc')
                    end
                  end.flatten.compact
                end
              },
              {
                title: 'provenance',
                fields: ['proxies.dctermsProvenance'],
              },
              {
                title: 'provenance',
                fields: ['proxies.dcSource'],
                exclude_vals: %w(ugc UGC)
              },
              {
                title: 'publisher',
                fields: ['proxies.dcPublisher'],
                search_field: 'proxy_dc_publisher',
                quoted: true
              },
              {
                title: 'identifier',
                fields: ['proxies.dcIdentifier']
              },
              {
                title: 'data-provider',
                fields: ['aggregations.edmDataProvider'],
                search_field: 'DATA_PROVIDER',
                ga_data: 'dimension3',
                quoted: true
              },
              {
                title: 'provider',
                fields: ['aggregations.edmProvider'],
                search_field: 'PROVIDER',
                ga_data: 'dimension4',
                quoted: true
              },
              {
                title: 'providing-country',
                fields: ['europeanaAggregation.edmCountry'],
                search_field: 'COUNTRY',
                ga_data: 'dimension2',
                quoted: true
              },
              {
                title: 'timestamp-created',
                fields: ['timestamp_created'],
                format_date: '%Y-%m-%d'
              },
              {
                title: 'timestamp-updated',
                fields: ['timestamp_update'],
                format_date: '%Y-%m-%d'
              }
            ]
          }
        end

        def properties
          {
            title: 'properties',
            sections: [
              {
                title: 'extent',
                fields: ['proxies.dctermsExtent']
              },
              {
                title: 'duration',
                fields: ['proxies.dcDuration']
              },
              {
                title: 'medium',
                fields: ['proxies.dcMedium']
              },
              {
                title: 'format',
                fields: ['proxies.dcFormat'],
                search_field: 'proxy_dc_format',
                quoted: true
              },
              {
                title: 'language',
                fields: ['proxies.dcLanguage'],
                search_field: 'dc_language',
                quoted: false
              }
            ]
          }
        end

        def refs_rels
          {
            title: 'refs-rels',
            sections: [
              {
                title: 'is-part-of',
                fields: ['proxies.dctermsIsPartOf'],
                search_field: 'proxy_dcterms_isPartOf',
                quoted: true
              },
              {
                title: 'collection-name',
                fields: ['europeanaCollectionName'],
                search_field: 'europeana_collectionName'
              },
              {
                title: 'relations',
                fields: ['proxies.dcRelation']
              },
              {
                title: 'references',
                fields: ['proxies.dctermsReferences']
              },
              {
                title: 'consists-of',
                fields: ['proxies.dctermsHasPart']
              },
              {
                title: 'version',
                fields: ['proxies.dctermsHasVersion']
              },
              {
                title: 'is-format-of',
                fields: ['proxies.dctermsIsFormatOf']
              },
              {
                title: 'is-referenced-by',
                fields: ['proxies.dctermsIsReferencedBy']
              },
              {
                title: 'is-replaced-by',
                fields: ['proxies.dctermsIsReplacedBy']
              },
              {
                title: 'is-required-by',
                fields: ['proxies.dctermsIsRequiredBy']
              },
              {
                title: 'edm.has-met',
                fields: ['proxies.edmHasMet']
              },
              {
                title: 'edm.incorporates',
                fields: ['proxies.edmIncorporates']
              },
              {
                title: 'edm.is-derivative-of',
                fields: ['proxies.edmIsDerivativeOf']
              },
              {
                title: 'edm.is-representation-of',
                fields: ['proxies.edmIsRepresentationOf']
              },
              {
                title: 'edm.is-similar-to',
                fields: ['proxies.edmIsSimilarTo']
              },
              {
                title: 'edm.is-successor-of',
                fields: ['proxies.edmIsSuccessorOf']
              },
              {
                title: 'edm.realises',
                fields: ['proxies.edmRealizes']
              },
              {
                title: 'edm.was-present-at',
                fields: ['proxies.wasPresentAt']
              }
            ]
          }
        end
      end
    end
  end
end
