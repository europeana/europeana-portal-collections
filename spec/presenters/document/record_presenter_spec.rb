# frozen_string_literal: true

RSpec.describe Document::RecordPresenter do
  let(:controller) { ActionView::TestCase::TestController.new }
  let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
  let(:document) { bl_response.documents.first }
  let(:basic_api_response) { JSON.parse(api_responses(:record, id: '123/abc')) }
  let(:api_response) { basic_api_response }

  describe '#media_rights' do
    subject { described_class.new(document, controller).media_rights }

    context 'with proxy dc:rights starting "http://rightsstatements.org/page/"' do
      let(:dc_rights) { 'http://rightsstatements.org/page/NoC-OKLR/1.0/?relatedURL=http://gallica.bnf.fr/html/conditions-dutilisation-des-contenus-de-gallica' }
      let(:api_response) do
        basic_api_response.tap do |record|
          record['object']['proxies'].first['dcRights'] = {
            def: [dc_rights]
          }
        end
      end

      it 'is used' do
        expect(subject).to eq(dc_rights)
      end
    end

    context 'without proxy dc:rights starting "http://rightsstatements.org/page/"' do
      let(:dc_rights) { 'http://example.org/dc/rights' }
      let(:edm_rights) { 'http://example.org/edm/rights' }
      let(:api_response) do
        basic_api_response.tap do |record|
          record['object']['proxies'].first['dcRights'] = {
            def: [dc_rights]
          }
          record['object']['aggregations'].first['edmRights'] = {
            def: [edm_rights]
          }
        end
      end

      it 'uses aggregation edm:rights' do
        expect(subject).to eq(edm_rights)
      end
    end
  end

  describe '#creators_info' do
    subject { described_class.new(document, controller).creators_info }

    context 'when the creator is a europeana entity' do
      let(:dc_creator) { 'http://data.europeana.eu/agent/base/157024' }
      let(:api_response) do
        basic_api_response.tap do |record|
          record['object']['proxies'].first['dcCreator'] = {
            def: [dc_creator]
          }
          record['object']['agents'] = [{
            about: dc_creator,
            prefLabel: { en: 'English Label', fr: 'Label Français', de: 'Deutsches Label' }
          }]
        end
      end

      it 'has europeana_entites set to true and sets the label and url' do
        expect(subject).to eq(creators: [{ title: 'English Label', data_path: '/en/explore/people/157024.json',
                                           human_path: '/en/explore/people/157024.html' }],
                              europeana_entities: true)
      end
    end

    context 'when the creator is a NON europeana entity' do
      let(:dc_creator) { 'http://wikidata.org/people/157024' }
      let(:api_response) do
        basic_api_response.tap do |record|
          record['object']['proxies'].first['dcCreator'] = {
            def: [dc_creator]
          }
          record['object']['agents'] = [{
                                          about: dc_creator,
                                          prefLabel: { en: 'English Label', fr: 'Label Français', de: 'Deutsches Label' }
                                        }]
        end
      end

      it 'has europeana_entites set to false and sets the label' do
        expect(subject).to eq(creators: [{ title: 'English Label' }],
                              europeana_entities: false)
      end
    end

    context 'when the creator is a europeana entity AND a NON europeana entity AND a string literal' do
      let(:dc_creator1) { 'http://data.europeana.eu/agent/base/157024' }
      let(:dc_creator2) { 'http://wikidata.org/people/157024' }
      let(:dc_creator3) { 'A string literal' }
      let(:api_response) do
        basic_api_response.tap do |record|
          record['object']['proxies'].first['dcCreator'] = {
            def: [dc_creator1, dc_creator2, dc_creator3]
          }
          record['object']['agents'] = [{
                                          about: dc_creator1,
                                          prefLabel: { en: 'English Label ONE', fr: 'Label Français UN', de: 'Deutsches Label EINS' }
                                        },
                                        {
                                          about: dc_creator2,
                                          prefLabel: { en: 'English Label TWO', fr: 'Label Français DEUX', de: 'Deutsches Label ZWEI' }
                                        }]

        end
      end

      it 'has europeana_entites set to true and sets the label and url' do
        expect(subject).to eq(creators: [{ title: 'English Label ONE', data_path: '/en/explore/people/157024.json',
                                           human_path: '/en/explore/people/157024.html' }],
                              europeana_entities: true)
      end
    end


    context 'when the creator is a string literal' do
      let(:dc_creator) { 'String Literal' }
      let(:api_response) do
        basic_api_response.tap do |record|
          record['object']['proxies'].first['dcCreator'] = {
            def: [dc_creator]
          }
        end
      end

      it 'has europeana_entites set to false and sets the label' do
        expect(subject).to eq(creators: [{ title: 'String Literal' }], europeana_entities: false)
      end
    end

    context 'when there is no creator' do
      let(:api_response) do
        basic_api_response.tap do |record|
          record['object']['proxies'].first.delete('dcCreator')
        end
      end

      it 'has europeana_entites set to false and no creators' do
        expect(subject).to eq(creators: [{ title: nil }], europeana_entities: false)
      end
    end
  end
end
