##
# URL helpers
module UrlHelper
  def track_solr_document_path(doc, options = {})
    url_for(options.merge(controller: :catalog,
                          action: :track,
                          provider_id: doc.provider_id,
                          record_id: doc.record_id))
  end

  def polymorphic_url(record_or_hash_or_array, options = {})
    doc = record_or_hash_or_array
    solr_document_url(options.merge(provider_id: doc.provider_id,
                                    record_id: doc.record_id))
  end

  def bookmark_path(doc, options = {})
    url_for(options.merge(controller: :bookmarks,
                          action: :show,
                          provider_id: doc.provider_id,
                          record_id: doc.record_id))
  end
end
