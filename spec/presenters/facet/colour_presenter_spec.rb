RSpec.describe Facet::ColourPresenter, presenter: :facet do
  let(:field_name) { 'COLOUR_FIELD' }
  let(:field_options) { { colour: true } }

  it_behaves_like 'a facet presenter'
  it_behaves_like 'a single-selectable facet'
  it_behaves_like 'a translator of item titles'
  it_behaves_like 'a field-showing/hiding presenter'

  describe '#display' do
    subject { presenter.display }

    it 'flags the facet as colour' do
      expect(subject[:colour]).to be(true)
    end

    it 'favours facet limit for showing/hiding split'
  end
end
