# frozen_string_literal: true

RSpec.describe Catalog do
  let(:controller_class) do
    Class.new(ApplicationController) do
      include Catalog
    end
  end

  let(:controller_params) { {} }
  let(:api_response) { JSON.parse(api_responses(:search_facet_creator)) }
  let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }

  subject { controller_class.new }

  before do
    allow(subject).to receive(:params) { controller_params }
  end

  describe '#add_collection_facet' do
    context 'with "all" collection' do
      let(:controller_params) { { controller: 'portal' } }

      it 'adds an additional facet field for "COLLECTION" with "all" on top' do
        expect(subject.send(:add_collection_facet, bl_response).items.first.value).to eq('all')
      end
    end

    context 'with non-"all" collection' do
      let(:controller_params) { { controller: 'collections', id: 'performing-arts' } }

      it 'adds an additional facet field for "COLLECTION" with the selected collection on top' do
        expect(subject.send(:add_collection_facet, bl_response).items.first.value).to eq('performing-arts')
      end

      it 'has "all" as the second value' do
        expect(subject.send(:add_collection_facet, bl_response).items.second.value).to eq('all')
      end
    end
  end
end
