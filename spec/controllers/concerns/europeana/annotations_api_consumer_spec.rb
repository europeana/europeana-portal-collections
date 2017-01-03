# frozen_string_literal: true

RSpec.describe Europeana::AnnotationsApiConsumer do
  before do
    class FakeController < ApplicationController
      include Europeana::AnnotationsApiConsumer
    end
  end

  after { Object.send :remove_const, :FakeController }
  let(:object) { FakeController.new }

  describe 'document_annotations' do
    let(:dummy_document) { double('dummy_document')}
    let(:dummy_annotation_search) { double('dummy_annotation_search', fetch: [])}

    before do
      allow(Europeana::API.annotation).to receive(:search).with('search_params') { dummy_annotation_search }
    end

    it 'should fetch the annotations from the API in paralllel then format them for display' do
      expect(object).to receive(:annotations_api_search_params).with(dummy_document) { 'search_params' }
      expect(Europeana::API).to receive(:in_parallel) { [{'body' => 'http://uri.one'}, { 'body' =>  { '@graph' => { 'sameAs'=> 'http://uri.two' }}}] }

      expect(object.document_annotations(dummy_document)).to eq(['http://uri.one', 'http://uri.two'])
    end
  end
end