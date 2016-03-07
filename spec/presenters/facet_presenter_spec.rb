require 'support/shared_examples/facet_presenter'

RSpec.describe FacetPresenter, presenter: :facet do
  it_behaves_like 'a facet presenter'

  describe '.build' do
    subject { described_class.build(facet, controller, blacklight_config) }

    context 'when facet is a simple field' do
      let(:facet) { facet_field_class.new('SIMPLE_FIELD', []) }
      it { is_expected.to be_a(Facet::SimplePresenter) }
    end

    context 'when facet is a hierarchical field' do
      context 'with no parent' do
        let(:facet) { facet_field_class.new('HIERARCHICAL_PARENT_FIELD', []) }
        it { is_expected.to be_a(Facet::HierarchicalPresenter) }
      end
      context 'with a parent' do
        let(:facet) { facet_field_class.new('HIERARCHICAL_CHILD_FIELD', []) }
        it { is_expected.to be_a(Facet::SimplePresenter) }
      end
    end

    context 'when facet is a boolean field' do
      let(:facet) { facet_field_class.new('BOOLEAN_FIELD', []) }
      it { is_expected.to be_a(Facet::BooleanPresenter) }
    end

    context 'when facet is a colour field' do
      let(:facet) { facet_field_class.new('COLOUR_FIELD', []) }
      it { is_expected.to be_a(Facet::ColourPresenter) }
    end

    context 'when facet is a range field' do
      let(:facet) { facet_field_class.new('RANGE_FIELD', []) }
      it { is_expected.to be_a(Facet::RangePresenter) }
    end
  end
end
