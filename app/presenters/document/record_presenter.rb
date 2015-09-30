module Document
  ##
  # Blacklight document presenter for a Europeana record
  class RecordPresenter < DocumentPresenter
    def edm_resource_url
      @edm_resource_url ||= @document.fetch('aggregations.edmIsShownBy', nil)
    end

    def media_web_resources(options)
      options.reverse_merge!(per_page: 4, page: 1)

      aggregation = @document.aggregations.first
      return [] unless aggregation.respond_to?(:webResources)

      view_urls = aggregation.fetch('hasView', []) + [aggregation.fetch('edmIsShownBy', nil)]
      web_resources = aggregation.webResources.dup
      edm_web_resource = web_resources.detect { |web_resource| web_resource.fetch('about', nil) == edm_resource_url }
      # make sure the edm_is_shown_by is the first item
      web_resources.unshift(web_resources.delete(edm_web_resource)) unless edm_web_resource.nil?
      web_resources.select! do |wr|
        view_urls.compact.include?(wr.fetch('about', nil)) ||
          Document::WebResourcePresenter.new(wr, @document, @controller).media_type == 'iiif'
      end
      web_resources.uniq! { |wr| wr.fetch('about', nil) }

      Kaminari.paginate_array(web_resources).page(options[:page]).per(options[:per_page])
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

      collections[collection]
    end
  end
end
