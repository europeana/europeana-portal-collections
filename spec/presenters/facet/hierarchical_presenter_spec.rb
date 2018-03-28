# frozen_string_literal: true

RSpec.describe Facet::HierarchicalPresenter, presenter: :facet do
  #   context 'when field is a hierarchical parent' do
  #     let(:field_name) { 'HIERARCHICAL_PARENT_FIELD' }
  #     let(:field_options) { { hierarchical: true } }

  #     before do
  #       blacklight_config.add_facet_field 'CHILD_FIELD', hierarchical: true, parent: 'PARENT_FIELD'
  #     end

  #     it_behaves_like 'a facet presenter'
  #     it_behaves_like 'a single-selectable facet'
  #     it_behaves_like 'a field-showing/hiding presenter'

  #     describe '#display' do
  #       subject { presenter.display }

  #       it 'flags the facet as hierarchical' do
  #         expect(subject[:hierarchical]).to be(true)
  #       end
  #     end
  #   end
end
