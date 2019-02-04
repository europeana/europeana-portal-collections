# frozen_string_literal: true

RSpec.describe SearchBuilder do
  subject { described_class.new controller }
  let(:controller) { CatalogController.new }
  before { allow(controller).to receive(:blacklight_config) { blacklight_config } }
  let(:blacklight_config) { Blacklight::Configuration.new }

  describe '#add_facetting_to_api' do
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

  describe '#add_profile_to_api' do
    context 'with hit highlighting enabled' do
      before do
        Rails.application.config.x.enable.hit_highlighting = '1'
      end

      it 'requests "hits" profile' do
        expect(subject.query[:profile].split(' ')).to include('hits')
      end
    end

    context 'without hit highlighting enabled' do
      before do
        Rails.application.config.x.enable.hit_highlighting = nil
      end

      it 'omits "hits" profile' do
        expect(subject.query[:profile].split(' ')).not_to include('hits')
      end
    end
  end

  describe '#add_hit_highlighting_to_api' do
    context 'with hit highlighting enabled' do
      before do
        Rails.application.config.x.enable.hit_highlighting = '1'
      end

      it 'sets hit.* parameters' do
        expect(subject.query['hit.selectors']).to eq(1)
        expect(subject.query['hit.fl']).to eq('fulltext.*')
      end
    end

    context 'without hit highlighting enabled' do
      before do
        Rails.application.config.x.enable.hit_highlighting = nil
      end

      it 'omits hit.* parameters' do
        expect(subject.query).not_to have_key('hit.selectors')
        expect(subject.query).not_to have_key('hit.fl')
      end
    end
  end
end
