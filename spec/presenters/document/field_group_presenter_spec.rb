RSpec.describe Document::FieldGroupPresenter, presenter: :field_group do

  let(:controller) { CatalogController.new }

  describe '.display' do
    subject { described_class.new(document, controller) }

    context 'when mapping values' do
      let(:field_group_id) { :provenance }

      context 'when the value maps to another value' do
        let(:api_response) { JSON.parse(api_responses(:record_with_edmugc, id: 'abc/123')) }
        let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
        let(:document) { bl_response.documents.first }
        it 'should show the translated mapped value' do
          expect(subject.display(field_group_id)[:sections].first[:items].first[:text]).to eq "User contributed content"
        end
      end

      context 'when the value maps to nil' do
        let(:api_response) { JSON.parse(api_responses(:record_with_edmugc_false, id: 'abc/123')) }
        let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
        let(:document) { bl_response.documents.first }
        it 'should not display anything' do
          expect(subject.display(field_group_id)).to eq nil
        end
      end
    end
  end
end
