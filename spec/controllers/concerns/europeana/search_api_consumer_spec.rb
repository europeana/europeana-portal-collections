# frozen_string_literal: true

RSpec.describe Europeana::SearchAPIConsumer do
  let(:controller_class) do
    Class.new(ApplicationController) do
      include Europeana::SearchAPIConsumer
    end
  end

  let(:controller_params) { {} }

  subject { controller_class.new }

  before do
    allow(subject).to receive(:params) { controller_params }
  end

  describe '#search_results_for_europeana_ids' do
    let(:europeana_ids) { %w(/123/abc /123/def) }

    it 'queries API for records by ID' do
      subject.send(:search_results_for_europeana_ids, europeana_ids)

      id_query = 'europeana_id:(' + europeana_ids.map { |id| %("#{id}") }.join(' OR ') + ')'

      expect(an_api_search_request.with(query: hash_including(
        query: id_query
      ))).to have_been_made.once
    end
  end

  describe '#search_results_for_dcterms_is_part_of' do
    let(:europeana_id) { '/123/abc' }

    it 'queries API for records by dcterms:isPartOf' do
      subject.send(:search_results_for_dcterms_is_part_of, europeana_id)
      expect(an_api_search_request.with(query: hash_including(
        query: %(proxy_dcterms_isPartOf:"http://data.europeana.eu/item#{europeana_id}")
      ))).to have_been_made.once
    end
  end
end
