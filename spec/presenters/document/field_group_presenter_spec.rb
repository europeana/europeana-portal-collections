# frozen_string_literal: true

RSpec.describe Document::FieldGroupPresenter, presenter: :field_group do
  let(:controller) { ActionView::TestCase::TestController.new }
  let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
  let(:document) { bl_response.documents.first }
  let(:basic_api_response) { JSON.parse(api_responses(:record, id: 'abc/123')) }
  let(:api_response) { basic_api_response }
  let(:field_group_id) { :test_field }

  before do
    allow(described_class).to receive(:definition).with(field_group_id).and_return(field_definition)
  end

  describe '#display' do
    subject { described_class.new(document, controller, field_group_id).display }

    describe 'title' do
      let(:field_definition) do
        {
          title: 'concepts',
          sections: [
            {
              fields: 'proxies.dcSubject'
            }
          ]
        }
      end
      let(:api_response) do
        basic_api_response.tap do |record|
          record['object']['proxies'].first['dcSubject'] = {
            def: %w(this that)
          }
        end
      end

      it 'is looked up from locales' do
        expect(subject[:title]).to eq(I18n.t('concepts', scope: 'site.object.meta-label'))
      end
    end

    describe 'sections' do
      describe 'title' do
        let(:field_definition) do
          {
            sections: [
              {
                title: 'subject',
                fields: %w(proxies.dcSubject)
              }
            ]
          }
        end
        let(:api_response) do
          basic_api_response.tap do |record|
            record['object']['proxies'].first['dcSubject'] = {
              def: %w(history music)
            }
          end
        end

        it 'is looked up from locales' do
          expect(subject[:sections].first[:title]).to eq(I18n.t('subject', scope: 'site.object.meta-label'))
        end
      end

      describe 'fields' do
        let(:field_definition) do
          {
            sections: [
              {
                fields: %w(proxies.dcSubject proxies.dcType)
              }
            ]
          }
        end
        let(:api_response) do
          basic_api_response.tap do |record|
            record['object']['proxies'].first['dcSubject'] = {
              def: %w(history music)
            }
            record['object']['proxies'].first['dcType'] = {
              def: %w(image)
            }
          end
        end

        it 'includes values from all fields' do
          expect(subject[:sections].first[:items].size).to eq(3)
        end
      end

      describe 'map_values' do
        let(:field_definition) do
          {
            sections: [
              {
                fields: 'aggregations.edmUgc',
                map_values: {
                  'true' => 'site.object.meta-label.ugc'
                }
              }
            ]
          }
        end
        let(:api_response) do
          basic_api_response.tap do |record|
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

      describe 'exclude_vals' do
        let(:excluded_values) { %w(history art) }
        let(:field_definition) do
          {
            sections: [
              {
                exclude_vals: excluded_values,
                fields: 'proxies.dcSubject'
              }
            ]
          }
        end
        let(:api_response) do
          basic_api_response.tap do |record|
            record['object']['proxies'].first['dcSubject'] = {
              def: %w(history music art fashion)
            }
          end
        end

        it 'removes excluded values' do
          expect(subject[:sections].first[:items].none? { |item| excluded_values.include?(item[:text]) }).to be true
        end

        it 'leaves other values' do
          expect(subject[:sections].first[:items].size).to eq(2)
        end
      end

      describe 'search_field' do
        let(:search_field) { 'what' }
        let(:field_definition) do
          {
            sections: [
              {
                search_field: search_field,
                quoted: quoted,
                fields: 'proxies.dcSubject'
              }
            ]
          }
        end
        let(:api_response) do
          basic_api_response.tap do |record|
            record['object']['proxies'].first['dcSubject'] = {
              def: %w(Photography)
            }
          end
        end

        context 'with quoted' do
          let(:quoted) { true }
          it 'links to a search for the quoted field value' do
            expect(CGI.unescape(subject[:sections].first[:items].first[:url])).to eq('/en/search?q=what:"Photography"')
          end

          context 'with parentheses in the value' do
            let(:api_response) do
              basic_api_response.tap do |record|
                record['object']['proxies'].first['dcSubject'] = {
                  def: ['With parentheses(in the string)[ok]']
                }
              end
            end

            it 'links to a search for the quoted field value' do
              expect(CGI.unescape(subject[:sections].first[:items].first[:url])).to eq('/en/search?q=what:"With parentheses(in the string)[ok]"')
            end
          end
        end

        context 'without quoted' do
          let(:quoted) { false }
          it 'links to a search for the parenthesised field value' do
            expect(CGI.unescape(subject[:sections].first[:items].first[:url])).to eq('/en/search?q=what:(Photography)')
          end
        end
      end

      describe 'capitalised' do
        let(:field_definition) do
          {
            sections: [
              {
                capitalised: capitalised,
                fields: 'proxies.dcLanguage'
              }
            ]
          }
        end
        let(:api_response) do
          basic_api_response.tap do |record|
            record['object']['proxies'].first['dcLanguage'] = {
              def: %w(english)
            }
          end
        end

        context 'when true' do
          let(:capitalised) { true }
          it 'capitalises field value' do
            expect(subject[:sections].first[:items].first[:text]).to eq('English')
          end
        end

        context 'when false' do
          let(:capitalised) { false }
          it 'does not touch field value' do
            expect(subject[:sections].first[:items].first[:text]).to eq('english')
          end
        end
      end

      describe 'format' do
        context 'when eq :date' do
          let(:field_definition) do
            {
              sections: [
                {
                  fields: 'timestamp_update',
                  format: :date
                }
              ]
            }
          end
          let(:api_response) do
            basic_api_response.tap do |record|
              record['object']['timestamp_update'] = field_value
            end
          end

          context 'with a timestamp value' do
            let(:field_value) { '2017-09-11T14:15:03.328Z' }
            it 'formats the date' do
              expect(subject[:sections].first[:items].first[:text]).to eq('2017-09-11')
            end
          end

          context 'with a non-date value' do
            let(:field_value) { 'Whenever' }
            it 'leaves it untouched' do
              expect(subject[:sections].first[:items].first[:text]).to eq(field_value)
            end
          end
        end
      end

      describe 'ga_data' do
        let(:field_definition) do
          {
            sections: [
              {
                ga_data: ga_data,
                fields: 'proxies.dcRights'
              }
            ]
          }
        end
        let(:api_response) do
          basic_api_response.tap do |record|
            record['object']['proxies'].first['dcRights'] = {
              def: %w(CC BY 4.0)
            }
          end
        end

        context 'when present' do
          let(:ga_data) { 'dimension1' }
          it 'is presented' do
            expect(subject[:sections].first[:items].first[:ga_data]).to eq('dimension1')
          end
        end

        context 'when blank' do
          let(:ga_data) { nil }
          it 'is not presented' do
            expect(subject[:sections].first[:items].first[:ga_data]).to be_nil
          end
        end
      end

      describe 'html_line_breaks' do
        let(:field_definition) do
          {
            sections: [
              {
                html_line_breaks: true,
                fields: 'proxies.dcDescription'
              }
            ]
          }
        end
        let(:api_response) do
          basic_api_response.tap do |record|
            record['object']['proxies'].first['dcDescription'] = {
              en: ["Line 1\n\nLine 2 & so on"]
            }
          end
        end
        it 'replaces new lines with HTML line breaks' do
          expect(subject[:sections].first[:items].first[:text]).to eq('Line 1<br/><br/>Line 2 &amp; so on')
        end
      end

      describe 'max' do
        let(:field_definition) do
          {
            sections: [
              {
                max: 5,
                fields: 'proxies.dcSubject'
              }
            ]
          }
        end
        let(:api_response) do
          basic_api_response.tap do |record|
            record['object']['proxies'].first['dcSubject'] = {
              def: %w(a b c d e f g h i j)
            }
          end
        end

        it 'limits the maximum number of field values' do
          expect(subject[:sections].first[:items].size).to eq(5)
        end
      end

      describe 'entity' do
        let(:entity_id) { '1234' }
        let(:entity_url) { "http://data.europeana.eu/#{entity_type}/base/#{entity_id}" }
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
        let(:api_response) do
          basic_api_response.tap do |record|
            record['object']['proxies'].first[proxy_field] = {
              def: [entity_url]
            }
            record['object'][entity_name] = [
              {
                about: entity_url,
                prefLabel: { en: ['Entity label'] }
              }
            ]
          end
        end

        context 'when entity is a Europeana agent' do
          let(:entity_type) { 'agent' }
          let(:entity_name) { 'agents' }
          let(:proxy_field) { 'dcCreator' }

          it 'uses the entity label for text' do
            expect(subject[:sections].first[:items].first[:text]).to eq('Entity label')
          end

          it 'links to the entity page' do
            expect(subject[:sections].first[:items].first[:url]).to eq('/en/explore/people/1234-entity-label.html')
          end

          it 'links to the entity json page' do
            expect(subject[:sections].first[:items].first[:json_url]).to eq('/en/explore/people/1234-entity-label.json')
          end

          it 'sets a entity flag to true' do
            expect(subject[:sections].first[:items].first[:entity]).to eq(true)
          end

          it 'sets a europeana_entity flag to true' do
            expect(subject[:sections].first[:items].first[:europeana_entity]).to eq(true)
          end
        end

        context 'when entity is a Europeana agent without the "base" namespace"' do
          let(:entity_type) { 'agent' }
          let(:entity_name) { 'agents' }
          let(:proxy_field) { 'dcCreator' }
          let(:entity_url) { "http://data.europeana.eu/#{entity_type}/#{entity_id}" }

          it 'uses the entity label for text' do
            expect(subject[:sections].first[:items].first[:text]).to eq('Entity label')
          end

          it 'links to the entity page' do
            expect(subject[:sections].first[:items].first[:url]).to eq('/en/explore/people/1234-entity-label.html')
          end

          it 'links to the entity json page' do
            expect(subject[:sections].first[:items].first[:json_url]).to eq('/en/explore/people/1234-entity-label.json')
          end

          it 'sets a europeana_entity flag to true' do
            expect(subject[:sections].first[:items].first[:europeana_entity]).to eq(true)
          end

          it 'sets a entity flag to true' do
            expect(subject[:sections].first[:items].first[:entity]).to eq(true)
          end
        end

        context 'when entity is a Europeana concept' do
          let(:entity_type) { 'concept' }
          let(:entity_name) { 'concepts' }
          let(:proxy_field) { 'dcFormat' }

          it 'uses the entity label for text' do
            expect(subject[:sections].first[:items].first[:text]).to eq('Entity label')
          end

          it 'links to the entity page' do
            expect(subject[:sections].first[:items].first[:url]).to eq('/en/explore/topics/1234-entity-label.html')
          end

          it 'links to the entity json page' do
            expect(subject[:sections].first[:items].first[:json_url]).to eq('/en/explore/topics/1234-entity-label.json')
          end

          it 'sets a europeana_entity flag to true' do
            expect(subject[:sections].first[:items].first[:europeana_entity]).to eq(true)
          end

          it 'sets a entity flag to true' do
            expect(subject[:sections].first[:items].first[:entity]).to eq(true)
          end
        end

        context 'when entity is a NON europeana entity' do
          let(:entity_name) { 'concepts' }
          let(:proxy_field) { 'dcFormat' }
          let(:entity_url) { "http://wikidata.org/concepts#{entity_id}" }

          it 'uses the entity label for text' do
            expect(subject[:sections].first[:items].first[:text]).to eq('Entity label')
          end

          it 'doe' do
            expect(subject[:sections].first[:items].first[:url]).to eq(nil)
          end

          it 'does NOT link to the entity json page' do
            expect(subject[:sections].first[:items].first[:json_url]).to eq(nil)
          end

          it 'sets a entity flag to true' do
            expect(subject[:sections].first[:items].first[:entity]).to eq(true)
          end

          it 'sets a europeana_entity flag to false' do
            expect(subject[:sections].first[:items].first[:europeana_entity]).to eq(false)
          end
        end

        describe 'fallback' do
          let(:entity_name) { 'concepts' }
          context 'without Europeana entity' do
            let(:field_definition) do
              {
                sections: [
                  {
                    entity: {
                      name: 'concepts',
                      fallback: entity_fallback
                    },
                    fields: %(proxies.dcSubject)
                  }
                ]
              }
            end
            let(:api_response) do
              basic_api_response.tap do |record|
                record['object']['proxies'].first['dcSubject'] = {
                  def: ['Dancing']
                }
              end
            end

            context 'when true' do
              let(:entity_fallback) { true }
              it 'displays other values' do
                expect(subject[:sections].first[:items]).not_to be_blank
                expect(subject[:sections].first[:items].first[:text]).to eq('Dancing')
              end
            end

            context 'when false' do
              let(:entity_fallback) { false }
              it 'displays nothing' do
                expect(subject).to be_blank
              end
            end
          end
        end
      end
    end
  end
end
