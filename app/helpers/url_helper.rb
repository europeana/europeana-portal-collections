##
# URL helpers
#
# @see Blacklight::UrlHelperBehavior
module UrlHelper
  include Blacklight::UrlHelperBehavior

  def url_for_document(doc, options = {})
    return super unless doc.is_a?(Europeana::Blacklight::Document)
    europeana_doc_url_params = {
      provider_id: doc.provider_id, record_id: doc.record_id, format: 'html'
    }
    document_path(europeana_doc_url_params)
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
    add_facet_params(field, item)
  end

  def track_document_path(doc, options = {})
    return super unless doc.is_a?(Europeana::Blacklight::Document)
    url_for(options.merge(controller: :catalog,
                          action: :track,
                          provider_id: doc.provider_id,
                          record_id: doc.record_id))
  end
  alias_method :track_solr_document_path, :track_document_path
  alias_method :track_europeana_blacklight_document_path, :track_document_path

  def polymorphic_url(record_or_hash_or_array, options = {})
    doc = record_or_hash_or_array
    if ! doc.is_a?(Europeana::Blacklight::Document)
      puts "No... #{doc.class}"
      sleep 2
    end
    return super unless doc.is_a?(Europeana::Blacklight::Document)
    document_url(options.merge(provider_id: doc.provider_id,
                               record_id: doc.record_id))
  end

  ##
  # Remove one value from qf params
  #
  # @param value Value to remove from qf params
  # @param source_params [Hash] params to use
  # @return [Hash] a copy of params with the passed value removed from qf
  def remove_qf_param(value, source_params = params)
    p = reset_search_params(source_params)
    p[:qf] = (p[:qf] || []).dup
    p[:qf] = p[:qf] - [value]
    p.delete(:qf) if p[:qf].empty?
    p
  end
end
