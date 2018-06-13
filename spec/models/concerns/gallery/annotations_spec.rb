# frozen_string_literal: true

RSpec.describe Gallery::Annotations do
  subject { instance }
  let(:instance) { Gallery.new(slug: gallery_slug) }
  let(:gallery_slug) { 'nice-pictures' }

  describe '#annotations' do
    subject { instance.annotations }

    it 'searches for related annotations' do
      allow(Europeana::Annotation).to receive(:find).with(qf: %w(param1 param2)) { %w(anno1 anno2) }
      expect(instance).to receive(:annotations_search_params) { { qf: %w(param1 param2) } }
      expect(subject).to eq(%w(anno1 anno2))
    end
  end

  describe '#annotations_search_params' do
    subject { instance.annotations_search_params }

    it 'is Hash with qf key' do
      expect(subject).to be_a(Hash)
      expect(subject).to have_key(:qf)
    end

    describe 'qf param' do
      subject { instance.annotations_search_params[:qf] }

      it 'is Array' do
        expect(subject).to be_a(Array)
      end

      it 'includes link_resource_uri filter' do
        allow(instance).to receive(:annotation_link_resource_uri) { 'http://www.example.com/gallery' }
        expect(subject).to include('link_resource_uri:"http://www.example.com/gallery"')
      end

      it 'includes creator_name filter' do
        expect(subject).to include('creator_name:"Europeana.eu Gallery"')
      end

      it 'includes link_relation filter' do
        expect(subject).to include('link_relation:isGatheredInto')
      end

      it 'includes motivation filter' do
        expect(subject).to include('motivation:linking')
      end
    end
  end

  describe '#annotation_link_resource_uri' do
    subject { instance.annotation_link_resource_uri }

    it 'uses the gallery URL' do
      expect(subject).to match(%r{/portal/explore/galleries/#{gallery_slug}})
    end
  end

  describe '#annotation_api_user_token' do
    before do
      Rails.application.config.x.europeana[:annotations].api_user_token_gallery = api_user_token
    end

    context 'with galleries user token configured' do
      let(:api_user_token) { 'token' }

      it 'returns configured token' do
        expect(subject.annotation_api_user_token).to eq(api_user_token)
      end
    end

    context 'without galleries user token configured' do
      let(:api_user_token) { nil }

      it 'returns empty string' do
        expect(subject.annotation_api_user_token).to eq('')
      end
    end
  end
end
