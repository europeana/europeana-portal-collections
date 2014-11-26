module BlacklightUrlHelper
  include Blacklight::UrlHelperBehavior
  
  def url_for_document(doc, options = {})
    # @optimize: 
    #   if doc.to_model.is_a? EuropeanaRecord
    if doc.respond_to?(:provider_id) and doc.respond_to?(:record_id)
      solr_document_path(provider_id: doc.provider_id, record_id: doc.record_id)
    else
      super
    end
  end

end
