# frozen_string_literal: true

RSpec.describe Europeana::Annotation do
  let(:api_url) { 'https://www.example.com/api' }
  let(:api_key) { 'annotations_api_key' }
  let(:api_user_token) { 'annotations_api_user_token' }

  let(:instance) { described_class.new(attributes) }
  let(:attributes) { { api_user_token: api_user_token } }

  before do
    Rails.application.config.x.europeana[:annotations].api_url = api_url
    Rails.application.config.x.europeana[:annotations].api_key = api_key
  end

  it 'includes ActiveModel::Model' do
    expect(described_class).to include(ActiveModel::Model)
  end

  describe '.find' do
    let(:api_method_url) { %(#{api_url}/annotations/search) }
    let(:params) { { query: 'fish' } }

    before do
      stub_request(:get, api_method_url).
        with(query: hash_including(wskey: api_key)).
        to_return(status: 200, body: '{"@context": "http://www.w3.org/ns/anno.jsonld","items":[]}', headers: { 'Content-Type' => 'application/ld+json' })
    end

    it 'queries the API for annotations' do
      described_class.find(params)

      expect(a_request(:get, api_method_url).
        with(query: { wskey: api_key, profile: 'standard', pageSize: 100 }.merge(params))).
        to have_been_made.once
    end
  end

  describe '.create' do
    let(:api_method_url) { %(#{api_url}/annotations/) }
    let(:attributes) { { api_user_token: api_user_token, motivation: 'tagging', bodyValue: 'tag', target: 'http://data.europeana.eu/item/abc/123' } }

    before do
      stub_request(:post, api_method_url).
        with(query: hash_including(userToken: api_user_token, wskey: api_key)).
        to_return(status: 200)
    end

    it 'creates the annotation via the API' do
      described_class.create(attributes)

      expect(a_request(:post, api_method_url).
        with(
          query: hash_including(userToken: api_user_token, wskey: api_key),
          body: attributes.except(:api_user_token).to_json
        )).
        to have_been_made.once
    end
  end

  describe '#delete' do
    let(:provider) { 'test' }
    let(:id) { '1234' }
    let(:api_method_url) { %(#{api_url}/annotations/#{provider}/#{id}) }

    let(:attributes) { { id: %(http://data.europeana.eu/annotation/#{provider}/#{id}), api_user_token: api_user_token } }

    before do
      stub_request(:delete, api_method_url).
        with(query: hash_including(userToken: api_user_token, wskey: api_key)).
        to_return(status: 204)
    end

    it 'deletes annotation from the API' do
      instance.delete

      expect(a_request(:delete, api_method_url).
        with(query: hash_including(userToken: api_user_token, wskey: api_key))).
        to have_been_made.once
    end
  end

  describe '#to_s' do
    subject { instance.to_s }

    before do
      instance.body = body
    end

    context 'when body is a String' do
      context 'and a URI' do
        let(:body) { 'http://www.example.com/entity/id' }
        it 'returns the body' do
          expect(subject).to eq(body)
        end
      end

      context 'but not a URI' do
        let(:body) { '/entity/id' }
        it 'does not return the body' do
          expect(subject).not_to eq(body)
        end
      end
    end

    context 'when body has a graph' do
      let(:body) { { '@graph' => body_graph } }
      let(:graph_same_as) { 'http://www.example.com/sameAs' }
      let(:graph_is_shown_at) { 'http://www.example.com/isShownAt' }
      let(:graph_is_shown_by) { 'http://www.example.com/isShownBy' }

      context 'with sameAs' do
        let(:body_graph) { { 'sameAs' => graph_same_as, 'isShownAt' => graph_is_shown_at, 'isShownBy' => graph_is_shown_by } }
        it 'returns sameAs' do
          expect(subject).to eq(graph_same_as)
        end
      end

      context 'with isShownAt' do
        let(:body_graph) { { 'isShownAt' => graph_is_shown_at, 'isShownBy' => graph_is_shown_by } }
        it 'returns isShownAt' do
          expect(subject).to eq(graph_is_shown_at)
        end
      end

      context 'with isShownBy' do
        let(:body_graph) { { 'isShownBy' => graph_is_shown_by } }
        it 'returns isShownBy' do
          expect(subject).to eq(graph_is_shown_by)
        end
      end

      context 'without sameAs, isShownAt or isShownBy' do
        let(:body_graph) { { 'otherProperty' => 'not for display' } }
        it { is_expected.to be_nil }
      end
    end
  end
end
