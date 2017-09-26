# frozen_string_literal: true

RSpec.describe 'entities/show.html.mustache', :common_view_components do
  include ActionView::Helpers::TextHelper

  before do
    assign(:entity, entity)
    assign(:params, type: human_type, id: id, locale: 'en')
    allow_any_instance_of(Entities::Show).to receive(:body_cache_key).and_return(['entities', type, id].join('/'))
    allow_any_instance_of(Entities::Show).to receive(:referenced_records).and_return(items_by: items_by_results)
    render
  end

  let(:items_by_results) do
    {
      search_reuslts: search_api_response[:items],
      total: {
        value: search_api_response[:totalResults],
        formatted: number_with_delimiter(search_api_response[:totalResults])
      }
    }
  end
  let(:id) { '123' }
  let(:type) { 'person' }
  let(:human_type) { 'people' }
  let(:api_response) do
    JSON.parse(api_responses(:entities_fetch_agent, name: 'Entity Name', description: 'Entity Description')).
      with_indifferent_access
  end
  let(:search_api_response) { JSON.parse(api_responses(:search)).with_indifferent_access }

  let(:entity) { EDM::Entity.build_from_params(type: type, id: id, api_response: api_response) }

  subject { rendered }

  it 'should have a title "Entity Name - Europeana Collections"' do
    expect(subject).to have_title('Entity Name - ' + t('site.name'))
  end

  it 'should have meta description'
  it 'should have meta HandheldFriendly' do
    expect(subject).to have_selector('meta[name="HandheldFriendly"]', visible: false)
  end

  it 'should have meta social media share links'

  it 'should have a title' do
    expect(subject).to have_selector("meta[property=\"og:title\"][content=\"#{entity.pref_label} - #{t('site.name')}\"]", visible: false)
  end

  describe '#entity_description_title' do
    context 'when entity type is agent' do
      it 'should use Biography as a label for the description' do
        expect(subject).to have_content('Biography')
      end
    end

    context 'when entity type is concept' do
      let(:type) { 'topic' }
      let(:api_response) do
        JSON.parse(api_responses(:entities_fetch_topic, name: 'Entity Name', description: 'Entity Description')).
          with_indifferent_access
      end
      it 'should use Description as a label for the description' do
        expect(subject).to have_content('Description')
      end
    end
  end

  describe 'noindex header tag' do
    context 'when the entity has no records relating to itself' do
      let(:items_by_results) { { search_results: [], total: { value: 0, formatted: '0' } } }
      it 'should be present' do
        expect(subject).to have_selector('meta[property="robots"][content="noindex"]', visible: false)
      end
    end

    context 'when the entity has no records relating to itself' do
      it 'should not be present' do
        expect(subject).to_not have_selector('meta[property="robots"][content="noindex"]', visible: false)
      end
    end
  end
end
