# frozen_string_literal: true

RSpec.describe 'entities/show.html.mustache', :common_view_components do
  include ActionView::Helpers::TextHelper

  before(:each) do
    assign(:entity, entity)
    assign(:body_cache_key,  ['entities', type, id].join('/'))
    assign(:params, {type: human_type, id: id, locale: 'en'} )
    render
  end

  let(:id) { '123' }
  let(:type) { 'person' }
  let(:human_type) { 'people' }
  let(:api_response) do
    JSON.parse(api_responses(:entities_fetch_agent, name: 'Entity Name', description: 'Entity Description')).
      with_indifferent_access
  end

  let(:entity) { EDM::Entity.build_from_params(type: type, id: id, api_response: api_response) }

  subject { rendered }

  it 'should have a title "Entity Name - Europeana Collections"' do
    expect(subject).to have_title('Entity Name - ' + t('site.name'))
  end

  it 'should have meta description'
  it 'should have meta HandheldFriendly'
  it 'should have meta social media share links'

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
      #  expect(subject).to have_content('Description')
      end
    end
  end
end
