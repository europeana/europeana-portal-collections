##
# BL facets helper
module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def facet_in_params?(field, item)
    value = facet_value_for_facet_item(item)
    super || (field =='CHANNEL' && within_channel? && (params[:id] == value))
  end

  private

  def create_facet_field_response_for_query_facet_field(facet_name, facet_field)
    salient_facet_queries = facet_field.query.map { |_k, x| x[:fq] }
    items = []

    response_facet_queris = @response.facet_queries.select do |k, _v|
      salient_facet_queries.include?(k)
    end
    response_facet_queris.reject! { |_value, hits| hits == 0 }
    response_facet_queris.each do |value, hits|
      salient_fields = facet_field.query.select do |_key, val|
        val[:fq] == value
      end
      key = ((salient_fields.keys if salient_fields.respond_to?(:keys)) || salient_fields.first).first
      items << Europeana::Blacklight::Response::Facets::FacetItem.new(value: key, hits: hits, label: facet_field.query[key][:label])
    end

    Europeana::Blacklight::Response::Facets::FacetField.new(facet_name, items)
  end
end
