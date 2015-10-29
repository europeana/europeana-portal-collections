RSpec.shared_examples 'facet param adder' do
  before do
    allow(helper).to receive(:facet_value_for_facet_item).and_return(item)
    allow(helper).to receive(:reset_search_params).and_return(params)
  end

  context 'facet is "COLLECTION"' do
    let(:field) { 'COLLECTION' }
    let(:item) { 'art' }
    let(:params) { { controller: 'catalog', action: 'index' } }

    it 'sets the collections controller and action params' do
      expect { subject[:controller].to eq('collections') }
      expect { subject[:action].to eq('show') }
    end

    it { is_expected.not_to have_key(:f) }
  end

  context 'facet is not "COLLECTION"' do
    let(:field) { 'YEAR' }
    let(:item) { '1950' }
    let(:params) { { controller: 'catalog', action: 'index' } }

    it 'does not sets the collections controller and action params' do
      expect { subject[:controller].to eq(params[:action]) }
      expect { subject[:action].to eq(params[:controller]) }
    end

    it 'sets facet in f param' do
      expect { subject[:f][field].to eq([item]) }
    end
  end
end

RSpec.describe UrlHelper, type: :helper do
  it { is_expected.to include(Blacklight::UrlHelperBehavior) }

  describe '#add_facet_params' do
    subject { helper.add_facet_params(field, item, params) }
    it_behaves_like 'facet param adder'
  end
end
