##
# Blacklight URL helpers
#
# @see Blacklight::UrlHelperBehavior
module BlacklightUrlHelper
  include Blacklight::UrlHelperBehavior

  def url_for_document(doc, options = {})
    unless doc.respond_to?(:provider_id) && doc.respond_to?(:record_id)
      return super
    end
    europeana_doc_url_params = {
      provider_id: doc.provider_id, record_id: doc.record_id, format: 'html'
    }
    solr_document_path(europeana_doc_url_params)
  end
end
