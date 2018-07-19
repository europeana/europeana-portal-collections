# frozen_string_literal: true

RSpec.describe Facet::CollectionPresenter, presenter: :facet do
  let(:field_name) { 'COLLECTION' }
  let(:field_options) { {} }
  let(:params) { { id: 'performing-arts' } }

  it_behaves_like 'a text-labelled facet item presenter'

  describe '#apply_order_to_items?' do
    subject { presenter.apply_order_to_items? }

    it 'orders the items' do
      expect(subject).to be(true)
    end
  end
end