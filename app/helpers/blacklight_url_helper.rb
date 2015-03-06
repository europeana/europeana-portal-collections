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

  def add_facet_params(field, item, source_params = params)
    return super unless field == 'CHANNEL'

    value = facet_value_for_facet_item(item)

    p = reset_search_params(source_params)
    p[:controller] = :channels
    p[:action] = :show
    p[:id] = value

    p
  end

  def add_facet_params_and_redirect(field, item)
    new_params = add_facet_params(field, item)

    return new_params if field == 'CHANNEL'

    # Delete any request params from facet-specific action, needed
    # to redir to index action properly.
    new_params.except! *Blacklight::Solr::FacetPaginator.request_keys.values

    new_params
  end
end
