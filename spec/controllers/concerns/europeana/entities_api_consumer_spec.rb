# frozen_string_literal: true

RSpec.describe Europeana::EntitiesApiConsumer do
  before do
    class FakeController < ApplicationController
      include Europeana::EntitiesApiConsumer
    end
  end

  after { Object.send :remove_const, :FakeController }
  let(:object) { FakeController.new }

  describe '#entities_api_type' do
    subject { object.entities_api_type(human_type) }

    context 'when human type is "people"' do
      let(:human_type) { 'people' }
      it { is_expected.to eq('agent') }
    end

    context 'when human type is "periods"' do
      let(:human_type) { 'periods' }
      it { is_expected.to eq('timespan') }
    end

    context 'when human type is "places"' do
      let(:human_type) { 'places' }
      it { is_expected.to eq('place') }
    end

    context 'when human type is "topics"' do
      let(:human_type) { 'topics' }
      it { is_expected.to eq('concept') }
    end
  end

  describe '#entity_url_slug' do
    subject { object.entity_url_slug(entity) }

    context 'when entity has no English prefLabel' do
      let(:entity) { { prefLabel: { fr: 'Paris' } } }
      it { is_expected.to be_nil }
    end

    context 'when entity has an English prefLabel' do
      let(:entity) { { prefLabel: { en: 'David Hume' } } }

      it 'should URLify it' do
        expect(subject).to eq('david-hume')
      end
    end
  end
end
