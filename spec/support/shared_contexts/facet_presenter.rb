# frozen_string_literal: true

RSpec.shared_context 'facet presenter', presenter: :facet do
  def facet_items(count)
    (1..count).map do |n|
      hits = (count + 1 - n) * 100
      value = case item_type
              when :text
                "Item#{n}"
              when :number
                n
              else
                fail
              end
      Europeana::Blacklight::Response::Facets::FacetItem.new(value: value, hits: hits)
    end
  end

  let(:item_type) { :text }

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
    end
  end

  let(:facet_field_class) { Europeana::Blacklight::Response::Facets::FacetField }

  let(:items) { [] }

  let(:facet) { facet_field_class.new(field_name, items) }

  let(:presenter) { described_class.new(facet, controller, blacklight_config) }

  let(:facet_item_text) { true }

  let(:field_options) { {} }
end
