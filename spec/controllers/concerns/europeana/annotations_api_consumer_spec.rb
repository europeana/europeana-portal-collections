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
    it 'should fetch the annotations from the API in paralllel then format them for display' do
      expect(object.document_annotations('/abc/123')).to eq(['http://data.europeana.eu/abc/123', 'http://data.europeana.eu/def/456'])
    end
  end
end
