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

  let(:europeana_document) { Europeana::Blacklight::Document.new }
  before do
    allow(europeana_document).to receive(:provider_id).and_return('abcd')
    allow(europeana_document).to receive(:record_id).and_return('1234')
  end

  let(:other_document) { double('other_document') }

  describe '#url_for_document' do
    context 'when document has record_id and provider_id' do
      subject { helper.url_for_document(europeana_document, extra: 'thing') }
      it { is_expected.to include('/record/abcd/1234.html') }
      it { is_expected.not_to include('extra=thing') }
    end

    context 'when document has no record_id or provider_id' do
      subject { helper.url_for_document(other_document) }
      it { is_expected.to eq(other_document) }
    end
  end
  
  describe '#add_facet_params' do
    subject { helper.add_facet_params(field, item, params) }
    it_behaves_like 'facet param adder'
  end

  describe '#add_facet_params_and_redirect' do
    subject { helper.add_facet_params_and_redirect(field, item) }
    it_behaves_like 'facet param adder'
  end

  describe '#track_document_path' do
    subject { helper.track_document_path(europeana_document, extra: 'thing') }
    it { is_expected.to include('/record/abcd/1234/track') }
    it { is_expected.to include('extra=thing') }
  end

  describe '#polymorphic_url' do
    subject { helper.polymorphic_url(europeana_document, extra: 'thing') }
    it { is_expected.to include('/record/abcd/1234') }
    it { is_expected.to include('extra=thing') }
  end

  describe '#remove_qf_param' do
    subject { helper.remove_qf_param('dog', { qf: ['dog', 'cat'] })[:qf] }
    it { is_expected.not_to include('dog') }
    it { is_expected.to include('cat') }
  end
end
