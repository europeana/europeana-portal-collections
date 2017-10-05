RSpec.describe Document::FieldGroupPresenter, presenter: :field_group do
  let(:controller) { CatalogController.new }
  let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
  let(:document) { bl_response.documents.first }

  before do
    allow(described_class).to receive(:definition).with(field_group_id).and_return(field_definition)
  end

  describe '#display' do
    subject { described_class.new(document, controller, field_group_id).display }

    context 'when mapping values' do
      let(:field_group_id) { :provenance }
      let(:field_definition) do
        {
          sections: [
            {
              fields: %(aggregations.edmUgc),
              map_values: {
                'true' => 'site.object.meta-label.ugc'
              }
            }
          ]
        }
      end
      let(:api_response) do
        JSON.parse(api_responses(:record, id: 'abc/123')).tap do |record|
          record['object']['aggregations'].first['edmUgc'] = field_value
        end
      end

      context 'when the value maps to another value' do
        let(:field_value) { 'true' }

        it 'maps and translate the value' do
          expect(subject[:sections].first[:items].first[:text]).to eq(I18n.t('site.object.meta-label.ugc'))
        end
      end

      context 'when the value is not mapped' do
        let(:field_value) { 'false' }

        it 'should be untouched' do
          expect(subject[:sections].first[:items].first[:text]).to eq(field_value)
        end
      end
    end

    context 'with entities' do
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
