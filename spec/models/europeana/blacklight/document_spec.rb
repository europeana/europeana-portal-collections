require 'rails_helper'

RSpec.describe Europeana::Blacklight::Document, type: :model do
  subject { described_class.new(edm) }

  let(:edm) {
    {
      id: '/abc/123',
      type: 'IMAGE',
      title: ['title1', 'title2'],
      proxies: [
        {
          about: '/proxy/provider/abc/123',
          dcType: {
            def: ['Image'],
            en: ['Picture']
          },
          dcSubject: {
            def: ['music', 'art']
          },
          dcDescription: {
            en: ['object desc']
          }
        }
      ],
      aggregations: [
        {
          webResources: [
            {
              dctermsCreated: 1900
            }
          ]
        }
      ],
      europeanaCompleteness: 5
    }
  }

  describe '#provider_id' do
    it 'returns first part of ID' do
      expect(described_class.new(edm).provider_id).to eq('abc')
    end
  end

  describe '#record_id' do
    it 'returns second part of ID' do
      expect(described_class.new(edm).record_id).to eq('123')
    end
  end

  describe '#to_param' do
    it 'joins provider ID and record ID with /' do
      expect(described_class.new(edm).to_param).to eq('abc/123')
    end
  end

  describe '#has?' do
    context 'with unnested key' do
      context 'when key is present' do
        subject { described_class.new(edm).has?('title') }
        it { is_expected.to eq(true) }
      end

      context 'when key is absent' do
        subject { described_class.new(edm).has?('missing') }
        it { is_expected.to eq(false) }
      end
    end

    context 'with nested key' do
      context 'when key is present' do
        subject { described_class.new(edm).has?('proxies.about') }
        it { is_expected.to eq(true) }
      end

      context 'when key is absent' do
        subject { described_class.new(edm).has?('foo.bar') }
        it { is_expected.to eq(false) }
      end

      context 'with values arg' do
        subject { described_class.new(edm).has?('proxies.about', '/proxy/provider/abc/123') }
        it 'is not implemented' do
          expect { subject }.to raise_error(NotImplementedError)
        end
      end
    end
  end

  describe '#as_json' do
    it 'includes hierarchy' do
      doc = described_class.new(edm)
      doc.hierarchy = double('hierarchy')
      expect(doc.as_json).to include('hierarchy')
    end
  end

  describe '#get' do
    it 'handles unnested keys' do
      expect(subject.get('type', sep: nil)).to eq('IMAGE')
    end
    
    it 'handles 2-level keys' do
      expect(subject.get('proxies.about')).to eq('/proxy/provider/abc/123')
    end
    
    it 'handles 3-level keys' do
      expect(subject.get('aggregations.webResources.dctermsCreated', sep: nil)).to eq([1900])
    end
    
    context 'when value is singular' do
      it 'is returned untouched' do
        expect(subject.get('europeanaCompleteness')).to eq(5)
      end
    end
    
    context 'when value is array' do
      context 'with separator arg' do
        it 'concats elements' do
          expect(subject.get('proxies.dcSubject', sep: ',')).to eq('music,art')
        end
      end
      context 'without separator arg' do
        it 'returns array of values' do
          expect(subject.get('proxies.dcSubject', sep: nil)).to eq(['music', 'art'])
        end
      end
    end
    
    context 'when value is hash' do
      context 'with key for current locale' do
        before do
          I18n.locale = :en
        end
        it 'returns current locale value' do
          expect(subject.get('proxies.dcType', sep: nil)).to eq(['Picture'])
        end
      end
      context 'with key "def"' do
        before do
          I18n.locale = :fr
        end
        it 'returns def value' do
          expect(subject.get('proxies.dcType', sep: nil)).to eq(['Image'])
        end
      end
      context 'without current locale or "def" keys' do
        before do
          I18n.locale = :es
        end
        it 'returns array of all values' do
          expect(subject.get('proxies.dcDescription', sep: nil)).to eq(['object desc'])
        end
      end
    end

    context 'when value is absent' do
      it 'does not raise an error' do
        expect { subject.get('absent.key') }.not_to raise_error
      end
      it 'returns nil' do
        expect(subject.get('absent.key')).to be_nil
      end
    end
  end

  describe '#more_like_this' do
    it 'returns an empty array' do
      expect(subject.more_like_this).to eq([])
    end
  end
end
