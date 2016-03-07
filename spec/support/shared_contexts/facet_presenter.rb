RSpec.shared_context 'facet presenter', presenter: :facet do
  def facet_items(count)
    (1..count).map do |n|
      Europeana::Blacklight::Response::Facets::FacetItem.new(value: "Item#{n}", hits: (count + 1 - n) * 100)
    end
  end

  let(:controller) do
    PortalController.new.tap do |controller|
      controller.request = ActionController::TestRequest.new
      params.each_pair do |k, v|
        controller.request.parameters[k] = v
      end
    end
  end

  let(:params) { {} }

  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.add_facet_field field_name, field_options
#       config.add_facet_field 'SIMPLE_FIELD'
#       config.add_facet_field 'HIERARCHICAL_PARENT_FIELD', hierarchical: true
#       config.add_facet_field 'HIERARCHICAL_CHILD_FIELD', hierarchical: true, parent: 'HIERARCHICAL_PARENT_FIELD'
#       config.add_facet_field 'BOOLEAN_FIELD', boolean: true
#       config.add_facet_field 'COLOUR_FIELD', colour: true
#       config.add_facet_field 'RANGE_FIELD', range: true
#       config.add_facet_field 'SINGLE_SELECT_FIELD', single: true
    end
  end

  let(:facet_field_class) { Europeana::Blacklight::Response::Facets::FacetField }

#   let(:facet) { facet_field_class.new(field_name, facet_items) }

  let(:items) { [] }

  let(:facet) { facet_field_class.new(field_name, items) }

  let(:presenter) { described_class.new(facet, controller, blacklight_config) }

  let(:facet_item_text) { true }
end
