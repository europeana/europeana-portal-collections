# frozen_string_literal: true

RSpec.describe Europeana::Annotation, :annotations_api do
  let(:instance) { described_class.new(attributes) }
  let(:attributes) { { api_user_token: annotations_api_user_token } }

  it 'includes ActiveModel::Model' do
    expect(described_class).to include(ActiveModel::Model)
  end

  describe '.find' do
    let(:params) { { query: 'fish' } }

    it 'queries the API for annotations' do
      described_class.find(params)

      expect(a_request(:get, annotations_api_search_method_url).
        with(query: { wskey: annotations_api_key, profile: 'standard', pageSize: '100' }.merge(params))).
        to have_been_made.once
    end
  end

  describe '.create' do
    let(:attributes) do
      {
        api_user_token: annotations_api_user_token,
        target: 'http://data.europeana.eu/item/abc/123',
        motivation: 'tagging',
        bodyValue: 'tag'
      }
    end

    it 'creates the annotation via the API' do
      described_class.create(attributes)

      expect(a_request(:post, annotations_api_create_method_url).
        with(
          query: hash_including(userToken: annotations_api_user_token, wskey: annotations_api_key),
          body: attributes.except(:api_user_token).to_json
        )).
        to have_been_made.once
    end
  end

  describe '#delete' do
    let(:provider) { 'test' }
    let(:id) { '1234' }

    let(:attributes) { { id: %(http://data.europeana.eu/annotation/#{provider}/#{id}), api_user_token: annotations_api_user_token } }

    it 'deletes annotation from the API' do
      instance.delete

      expect(a_request(:delete, %(#{annotations_api_url}/annotations/#{provider}/#{id})).
        with(query: hash_including(userToken: annotations_api_user_token, wskey: annotations_api_key))).
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
