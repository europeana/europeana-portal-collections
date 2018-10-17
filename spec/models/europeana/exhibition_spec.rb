# frozen_string_literal: true

RSpec.describe Europeana::Exhibition, :exhibitions_json do
  it 'includes ActiveModel::Model' do
    expect(described_class).to include(ActiveModel::Model)
  end

  describe '.find' do
    let(:exhibitions_host) { 'https://europeana.eu' }
    let(:configured_exhibitions_host) { exhibitions_host }
    let(:exhibition_slug) { 'test-exhibition' }
    let(:exhibition_url) { "#{exhibitions_host}/portal/en/exhibitions/#{exhibition_slug}" }

    let(:subject) { described_class.find(exhibition_url) }

    before do
      Rails.application.config.x.exhibitions.host_url = configured_exhibitions_host
      subject # Calling subject in order to run .find for shared examples which don't explicitly call anything.
    end

    it_behaves_like 'an exhibitions JSON request'
    it 'retruns a new instance of a Europeana::Exhibition' do
      expect(subject).to be_a(described_class)
    end

    context 'when the url passed does NOT match the url pattern' do
      let(:exhibition_url) { "#{exhibitions_host}/portal/en/explore/galleries/#{exhibition_slug}" }

      it_behaves_like 'no exhibitions JSON request'
      it 'should be nil' do
        expect(subject).to be_nil
      end
    end

    context 'when a unique exhibition_host is specified' do
      let(:configured_exhibitions_host) { 'http://host.example' }

      context 'when the url complies' do
        let(:exhibitions_host) { 'http://host.example' }

        it_behaves_like 'an exhibitions JSON request'
        it 'retruns a new instance of a Europeana::Exhibition' do
          expect(subject).to be_a(described_class)
        end
      end

      context 'when the url does NOT comply' do
        it_behaves_like 'no exhibitions JSON request'
        it 'should be nil' do
           expect(subject).to be_nil
        end
      end
    end
  end

  describe '.exhibition?' do
    let(:subject) { described_class.exhibition?(url) }

    context 'when the url matches' do
      let(:url) { 'https://europeana.eu/portal/en/exhibitions/faces-of-europe'}

      it 'should be true' do
        expect(subject).to  be_truthy
      end
    end

    context 'when the url is NOT for an exhibiton' do
      let(:url) { 'https://europeana.eu/portal/en/explore/galleries/faces-of-europe'}

      it 'should be false' do
        expect(subject).to_not  be_truthy
      end
    end
  end

  describe '#exhibition_root?' do
    let(:subject) { described_class.new(depth: depth).exhibition_root? }

    context 'when the exhibition is the root' do
      let(:depth) { 2 }

      it 'should return true' do
        expect(subject).to be_truthy
      end
    end

    context 'when the exhibition is a foyer page' do
      let(:depth) { 1 }

      it 'should return true' do
        expect(subject).to_not be_truthy
      end
    end
    context 'when the exhibition is a child page' do
      let(:depth) { 3 }

      it 'should return true' do
        expect(subject).to_not be_truthy
      end
    end
  end
end
