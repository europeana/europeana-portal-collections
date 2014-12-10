module UrlHelper
  def track_solr_document_path(doc, options = {})
    url_for(options.merge(controller: :catalog, action: :track, provider_id: doc.provider_id, record_id: doc.record_id))
  end
  
  def polymorphic_url(record_or_hash_or_array, options = {})
    if record_or_hash_or_array.is_a?(SolrDocument)
      doc = record_or_hash_or_array
      solr_document_url(options.merge(provider_id: doc.provider_id, record_id: doc.record_id))
    else
      super
    end
  end
end
