require 'support/shared_examples/facet_presenter'

RSpec.describe Facet::SimplePresenter, presenter: :facet do
  it_behaves_like 'a facet presenter'

  describe '#display' do
    let(:facet) { facet_field_class.new('SIMPLE_FIELD', []) }
    let(:options) { {} }
    subject { described_class.new(facet, controller, blacklight_config).display(options) }

    it 'is flagged as simple' do
      expect(subject[:simple]).to be(true)
    end
  end
end
