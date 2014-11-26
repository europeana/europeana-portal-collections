module ApplicationHelper
  # @todo: un-hard-code "catalog"
  def track_solr_document_path(doc, options = {})
    url_for(options.merge(controller: "catalog", action: :track, provider_id: doc.provider_id, record_id: doc.record_id))
  end
end
