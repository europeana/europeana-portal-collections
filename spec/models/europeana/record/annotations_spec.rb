# frozen_string_literal: true

RSpec.describe Europeana::Record::Annotations do
  let(:including_class) do
    Class.new do
      include Europeana::Record::Annotations
      attr_accessor :id
    end
  end

  let(:instance_id) { '/abc/123' }

  let(:instance) do
    including_class.new.tap do |instance|
      instance.id = instance_id
    end
  end

  subject { instance }

  describe '#annotations' do
    subject { instance.annotations }

    it 'searches for related annotations' do
      allow(Europeana::Annotation).to receive(:find).with(qf: %w(param1 param2)) { %w(anno1 anno2) }
      expect(instance).to receive(:annotations_search_params) { { qf: %w(param1 param2) } }
      expect(subject).to eq(%w(anno1 anno2))
    end
  end

  describe '#annotations_search_params' do
    subject { instance.annotations_search_params(creator_name: creator_name) }
    let(:creator_name) { 'With Space' }

    it 'is Hash with qf, sort, sortOrder and pageSize keys' do
      expect(subject).to be_a(Hash)
      expect(subject).to have_key(:qf)
      expect(subject).to have_key(:sort)
      expect(subject).to have_key(:sortOrder)
      expect(subject).to have_key(:pageSize)
    end

    describe 'qf param' do
      subject { instance.annotations_search_params(creator_name: creator_name)[:qf] }

      it 'is Array' do
        expect(subject).to be_a(Array)
      end

      it 'includes generator_name filter' do
        allow(instance).to receive(:annotations_api_generator_name) { 'Generator' }
        expect(subject).to include('generator_name:Generator')
      end

      it 'includes the escaped creator_name filter' do
        expect(subject).to include(%(creator_name:With\\ Space))
      end

      it 'includes target_record_id filter' do
        expect(subject).to include(%(target_record_id:"#{instance_id}"))
      end

      context 'when no creator_name is supplied' do
        subject { instance.annotations_search_params[:qf] }

        it 'includes a wildcard creator_name filter' do
          expect(subject).to include(%(creator_name:*))
        end
      end
    end

    describe 'sorting params' do
      describe 'sort' do
        subject { instance.annotations_search_params[:sort] }

        it 'is "created"' do
          expect(subject).to eq 'created'
        end
      end

      describe 'sortOrder' do
        subject { instance.annotations_search_params[:sortOrder] }

        it 'is "desc"' do
          expect(subject).to eq 'desc'
        end
      end
    end

    describe 'pageSize param' do
      context 'when no limit is supplied' do
        subject { instance.annotations_search_params[:pageSize] }

        it 'is defaults to 100' do
          expect(subject).to eq 100
        end
      end

      context 'when a limit is supplied' do
        subject { instance.annotations_search_params(limit: 1)[:pageSize] }

        it 'is uses the limit' do
          expect(subject).to eq 1
        end
      end
    end
  end

  describe '#annotations_api_generator_name' do
    subject { instance.annotations_api_generator_name }

    context 'when config is set' do
      before do
        Rails.application.config.x.europeana[:annotations].api_generator_name = 'Custom Generator'
      end

      it 'uses config' do
        expect(subject).to eq('Custom Generator')
      end
    end

    context 'when config is not set' do
      before do
        Rails.application.config.x.europeana[:annotations].api_generator_name = nil
      end

      it 'uses default' do
        expect(subject).to eq('Europeana.eu*')
      end
    end
  end

  describe '#annotation_target_uri' do
    subject { instance.annotation_target_uri }

    it 'uses ID in data.europeana.eu URI' do
      expect(subject).to eq("http://data.europeana.eu/item#{instance_id}")
    end
  end

  describe '#escape_query_value' do
    subject { instance.escape_query_value(value) }
    let(:value) { 'Simple' }

    context 'whhen value is simple' do
      it 'returns the value as was' do
        expect(subject).to eq(value)
      end
    end

    context 'when the value contains a space' do
      let(:value) { 'With Space' }

      it 'escapes the spaces' do
        expect(subject).to eq('With\ Space')
      end
    end
  end
end
