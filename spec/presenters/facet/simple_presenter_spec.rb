RSpec.describe Facet::SimplePresenter, presenter: :facet do
  let(:field_name) { 'SIMPLE_FIELD' }
  let(:field_options) { {} }

  it_behaves_like 'a facet presenter'
  it_behaves_like 'a single-selectable facet'
  it_behaves_like 'a text-labelled facet item presenter'
  it_behaves_like 'a field-showing/hiding presenter'

  describe '#display' do
    subject { presenter.display }

    it 'flags the facet as simple' do
      expect(subject[:simple]).to be(true)
    end
  end
end
