require 'rails_helper'

RSpec.shared_examples 'facet param adder' do
  before do
    allow(helper).to receive(:facet_value_for_facet_item).and_return(item)
    allow(helper).to receive(:reset_search_params).and_return(params)
  end

  context 'facet is "CHANNEL"' do
    let(:field) { 'CHANNEL' }
    let(:item) { 'art' }
    let(:params) { { controller: 'catalog', action: 'index' } }

    it 'sets the channels controller and action params' do
      expect { subject[:controller].to eq('channels') }
      expect { subject[:action].to eq('show') }
    end

    it { is_expected.not_to have_key(:f) }
  end

  context 'facet is not "CHANNEL"' do
    let(:field) { 'YEAR' }
    let(:item) { '1950' }
    let(:params) { { controller: 'catalog', action: 'index' } }

    it 'does not sets the channels controller and action params' do
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
