module Document
  ##
  # Blacklight document presenter for a Europeana record
  class RecordPresenter < DocumentPresenter
    def edm_is_shown_by
      @edm_is_shown_by ||= render_document_show_field_value('aggregations.edmIsShownBy')
    end

    def edm_object
      @edm_object ||= aggregation.fetch('edmObject', nil)
    end

    def aggregation
      @first_aggregation ||= @document.aggregations.first
    end

    def is_shown_by_or_at
      aggregation.fetch('edmIsShownBy', nil) || aggregation.fetch('edmIsShownAt', nil)
    end

    def has_views
      @has_views ||= aggregation.fetch('hasView', []).compact
    end

    def edm_is_shown_by_web_resource
      @edm_is_shown_by_web_resource ||= begin
        web_resources.detect do |web_resource|
          web_resource.fetch('about', nil) == edm_is_shown_by
        end
      end
    end

    def web_resources
      @web_resources ||= begin
        aggregation.respond_to?(:webResources) ? aggregation.webResources : []
      end
    end

    def edm_object_thumbnails_edm_is_shown_by?
      edm_is_shown_by.present? && edm_object.present? && (edm_object != edm_is_shown_by)
    end

    def media_web_resource_presenters
      return [] if web_resources.blank?

      @media_web_resource_presenters ||= begin
        salient_web_resources = web_resources.dup.tap do |web_resources|
          # make sure the edm_is_shown_by is the first item
          unless edm_is_shown_by_web_resource.nil?
            web_resources.unshift(web_resources.delete(edm_is_shown_by_web_resource))
          end
          web_resources.uniq! { |web_resource| web_resource.fetch('about', nil) }
        end
        presenters = salient_web_resources.map do |web_resource|
          Document::WebResourcePresenter.new(web_resource, @controller, @configuration, @document, self)
        end
      end
    end

    def displayable_media_web_resource_presenters
      media_web_resource_presenters.select(&:displayable?)
    end

    def media_web_resources(options = {})
      Kaminari.paginate_array(displayable_media_web_resource_presenters).
        page(options[:page]).per(options[:per_page])
    end

    # iiif manifests can be derived from some dc:identifiers - on a collection basis or an individual item basis - or from urls
    def iiif_manifesto
      @iiif_manifesto ||= begin
        iiif_manifesto_by_record_id || iiif_manifesto_by_identifier || iiif_manifesto_by_collection
      end
    end

    def media_rights
      @media_rights ||= render_document_show_field_value('aggregations.edmRights')
    end

    def iiif_manifesto_by_record_id
      record_id = render_document_show_field_value('about')
      if record_id_match = record_id.match(%r{/07927/diglit_(.*)})
        'http://digi.ub.uni-heidelberg.de/diglit/iiif/' + record_id_match[1] + '/manifest.json'
      end
    end

    def iiif_manifesto_by_identifier
      identifier = render_document_show_field_value('proxies.dcIdentifier')

      ids = {
        # test url: http://localhost:3000/portal/record/9200365/BibliographicResource_3000094705862.html?debug=json
        'http://gallica.bnf.fr/ark:/12148/btv1b84539771' => 'http://iiif.biblissima.fr/manifests/ark:/12148/btv1b84539771/manifest.json',
        # test url: http://localhost:3000/portal/record/92082/BibliographicResource_1000157170184.html?debug=json
        'http://gallica.bnf.fr/ark:/12148/btv1b10500687r' => 'http://iiif.biblissima.fr/manifests/ark:/12148/btv1b10500687r/manifest.json'
      }

      ids[identifier]
    end

    def iiif_manifesto_by_collection
      identifier = render_document_show_field_value('proxies.dcIdentifier')
      return nil unless identifier.present?

      collection = render_document_show_field_value('europeanaCollectionName')
      collections = {}

      # test url: http://localhost:3000/portal/record/9200175/BibliographicResource_3000004673129.html?debug=json
      # or any result from: http://localhost:3000/portal/search?q=europeana_collectionName%3A9200175_Ag_EU_TEL_a1008_EU_Libraries_Bodleian
      if identifier.match('.+/uuid')
        collections['9200175_Ag_EU_TEL_a1008_EU_Libraries_Bodleian'] = identifier.sub(identifier.match('.+/uuid')[0], 'http://iiif.bodleian.ox.ac.uk/iiif/manifest') + '.json'
      end

      # test url: http://localhost:3000/portal/record/9200173/9B976C77421CE43F3BDA72EF47BCCC08AF94A238.html?debug=json
      if collection.match('9200173')
        numeric_part = identifier.split('llgc-id:')
        if numeric_part.size > 1
          numeric_part = numeric_part[1].split(',')[0]
          collections[collection] = 'http://dams.llgc.org.uk/iiif/2.0/' + numeric_part + '/manifest.json'
        end
      end
      collections[collection]
    end
  end
end
