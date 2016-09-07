# frozen_string_literal: true

RSpec.describe SearchBuilder do
  let(:controller) { CatalogController.new }
  before { allow(controller).to receive(:blacklight_config) { blacklight_config } }

  it { expect(described_class).to be < Europeana::Blacklight::SearchBuilder }

  describe '#add_facetting_to_api' do
    subject { described_class.new controller }

    context 'when a facet field is aliased' do
      let(:blacklight_config) do
        Blacklight::Configuration.new do |config|
          config.add_facet_field 'proxy_dc_format.en'
          config.add_facet_field 'colour', aliases: 'proxy_dc_format.en'
          config.add_facet_fields_to_solr_request!
        end
      end

      it 'should use the aliased facet name' do
        expect(subject.query['facet']).to include 'proxy_dc_format.en'
        expect(subject.query['facet']).to_not include 'colour'
      end
    end
  end

  describe '#add_facet_qf_to_api' do
    subject { described_class.new controller }

    context 'when a facet field is aliased' do
      let(:blacklight_config) do
        Blacklight::Configuration.new do |config|
          config.add_facet_field 'proxy_dc_format.en', limit: 20
          config.add_facet_field 'colour', aliases: 'proxy_dc_format.en'
          config.add_facet_fields_to_solr_request!
        end
      end

      it 'should use the aliased qf_field name' do
        expect(subject.with(f: { 'colour' => ['yellow'] }).query[:qf]).to include 'proxy_dc_format.en:"yellow"'
        expect(subject.with(f: { 'colour' => ['yellow'] }).query[:qf]).to_not include 'colour:"yellow"'
      end
    end
  end

  describe '#salient_facets_for_api_facet_qf' do
    subject { described_class.new controller }

    let(:blacklight_config) do
      Blacklight::Configuration.new do |config|
        config.add_facet_field 'CREATOR',
                               when: ->(context) { context.within_collection? && context.current_collection.key == 'fashion' },
                               limit: 100,
                               only: ->(item) { item.value.end_with?(' (Designer)') }
        config.add_facet_fields_to_solr_request!
      end
    end

    it 'should return the facet with the passed value' do
      expect(subject.with(f: { 'CREATOR' => ['Me'] }).salient_facets_for_api_facet_qf).to eq('CREATOR' => ['Me'])
    end

    context 'when a facet field is aliased' do
      let(:blacklight_config) do
        Blacklight::Configuration.new do |config|
          config.add_facet_field 'proxy_dc_format.en', limit: 20
          config.add_facet_field 'colour', aliases: 'proxy_dc_format.en'
          config.add_facet_fields_to_solr_request!
        end
      end

      it 'should return the aliased facet with the passed value' do
        expect(subject.with(f: { 'colour' => ['yellow'] }).salient_facets_for_api_facet_qf).to eq('proxy_dc_format.en' => ['yellow'])
      end
    end
  end
end
