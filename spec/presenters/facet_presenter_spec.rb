RSpec.describe FacetPresenter, presenter: :facet do
  let(:field_name) { 'GENERIC_FIELD' }

  it_behaves_like 'a single-selectable facet'
  it_behaves_like 'a translator of item titles'

  describe '.build' do
    subject { described_class.build(facet, controller, blacklight_config) }

    context 'when facet is a simple field' do
      let(:field_options) { {} }
      it { is_expected.to be_a(Facet::SimplePresenter) }
    end

    context 'when facet is a hierarchical field' do
      context 'with no parent' do
        let(:field_options) { { hierarchical: true } }
        it { is_expected.to be_a(Facet::HierarchicalPresenter) }
      end
      context 'with a parent' do
        let(:field_options) { { hierarchical: true, parent: 'PARENT_FIELD' } }
        it { is_expected.to be_a(Facet::SimplePresenter) }
      end
    end

    context 'when facet is a boolean field' do
      let(:field_options) { { boolean: true } }
      it { is_expected.to be_a(Facet::BooleanPresenter) }
    end

    context 'when facet is a colour field' do
      let(:field_options) { { colour: true } }
      it { is_expected.to be_a(Facet::ColourPresenter) }
    end

    context 'when facet is a range field' do
      let(:field_options) { { range: true } }
      it { is_expected.to be_a(Facet::RangePresenter) }
    end
  end
end
