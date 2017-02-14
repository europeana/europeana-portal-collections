RSpec.describe RailsAdmin.config do
  describe '#included_models' do
    subject { RailsAdmin.config.included_models }
    it { is_expected.to eq(%w(Banner BrowseEntry Collection DataProvider DataProviderLogo FacetLinkGroup Gallery HeroImage Link Link::Promotion Link::Credit Link::SocialMedia MediaObject Page Page::Error Page::Landing Topic User)) }
  end

  describe '#model' do
    let(:model) { RailsAdmin.config.models.find { |m| m.abstract_model.model_name == model_name } }

    %w(Banner BrowseEntry Collection Gallery Page Page::Error Page::Landing Topic User).each do |model_name|
      context "when model is #{model_name}" do
        let(:model_name) { model_name }
        it 'should be visible' do
          expect(model.visible).to be true
        end
      end
    end

    %w(HeroImage Link MediaObject).each do |model_name|
      context "when model is #{model_name}" do
        let(:model_name) { model_name }
        it 'should not be visible' do
          expect(model.visible).to be false
        end
      end
    end
  end
end
