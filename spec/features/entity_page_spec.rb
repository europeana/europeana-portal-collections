# frozen_string_literal: true

RSpec.feature 'Entity page' do
  let(:mime_type) { 'application/vnd.api+json' }

  describe 'entity page' do
    let(:namespace) { 'base' }
    let(:id) { '1234' }
    let(:wskey) { Rails.application.config.x.europeana[:entities].api_key }
    let(:url) { %r(#{Europeana::API.url}/entities/#{type}/#{namespace}/#{id}) }
    let(:headers) { { 'Content-Type' => 'application/ld+json' } }

    context 'type is agent' do
      let(:type) { 'agent' }
      let(:name) { 'David Hume' }
      let(:description) { 'A famous philosopher' }

      it 'has title "David Hume - Europeana Collections"' do
        stub_request(:get, url).
          to_return(status: 200, body: api_responses(:entities_fetch_agent, name: name, description: description),
                    headers: headers)
        visit entity_path(:en, 'people', id)
        expect(page).to have_title("#{name} - Europeana Collections", exact: true)
        expect(page).to have_selector('.entity-title', text: name)
        expect(all('.anagraphical-datum h3').length).to_not be_zero
        expect(page).to have_selector('.summary-column p', text: description)
      end
    end

    context 'type is concept' do
      let(:type) { 'concept' }
      let(:name) { 'Photography' }
      let(:description) { 'The art of taking pictures' }

      it 'has title "Photography - Europeana Collections"' do
        stub_request(:get, url).
          to_return(status: 200, body: api_responses(:entities_fetch_topic, name: name, description: description),
                    headers: headers)
        visit entity_path(:en, 'topics', id)
        expect(page).to have_title("#{name} - Europeana Collections", exact: true)
        expect(page).to have_selector('.entity-title', text: name)
        expect(all('.anagraphical-datum h3').length).to be_zero
        expect(page).to have_selector('.summary-column p', text: description)
      end
    end
  end
end
