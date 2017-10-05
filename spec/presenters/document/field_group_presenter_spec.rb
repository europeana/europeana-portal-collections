# frozen_string_literal: true

RSpec.describe Document::FieldGroupPresenter, presenter: :field_group do
  let(:controller) { CatalogController.new }
  let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
  let(:document) { bl_response.documents.first }

  describe '#display' do
    subject { described_class.new(document, controller, field_group_id).display }

    context 'when mapping values' do
      let(:field_group_id) { :provenance }

      context 'when the value maps to another value' do
        let(:api_response) { JSON.parse(api_responses(:record_with_edmugc, id: 'abc/123')) }
        it 'should show the translated mapped value' do
          expect(subject[:sections].first[:items].first[:text]).to eq 'User contributed content'
        end
      end

      context 'when the value maps to nil' do
        let(:api_response) { JSON.parse(api_responses(:record_with_edmugc_false, id: 'abc/123')) }
        it 'should not display anything' do
          expect(subject).to eq nil
        end
      end
    end

    context 'with entities' do
      before do
        allow(described_class).to receive(:definition).with(field_group_id).and_return(field_definition)
      end

      let(:field_definition) do
        {
          sections: [
            {
              entity: {
                name: entity_name
              },
              fields: %(proxies.#{proxy_field})
            }
          ]
        }
      end

      context 'when entity is a Europeana agent' do
        let(:field_group_id) { :people }
        let(:entity_name) { 'agents' }
        let(:proxy_field) { 'dcCreator' }
        let(:api_response) { JSON.parse(api_responses(:record_with_entity_agent, id: 'abc/123', identifier: '1234', proxy_field: proxy_field)) }

        it 'links to the entity page' do
          expect(subject[:sections].first[:items].first[:url]).to match(%r{^/en/explore/people/1234-})
        end
      end

      context 'when entity is a Europeana concept' do
        let(:field_group_id) { :properties }
        let(:entity_name) { 'concepts' }
        let(:proxy_field) { 'dcFormat' }
        let(:api_response) { JSON.parse(api_responses(:record_with_entity_concept, id: 'abc/123', identifier: '1234', proxy_field: proxy_field)) }

        it 'links to the entity page' do
          expect(subject[:sections].first[:items].first[:url]).to match(%r{^/en/explore/topics/1234-})
        end
      end
    end
  end
end
