RSpec.describe RailsAdmin.config do
  describe '#included_models' do
    subject { RailsAdmin.config.included_models }
    it { is_expected.to eq(%w(Banner BrowseEntry BrowseEntry::FacetEntry Collection DataProvider DataProviderLogo HeroImage Link Link::Promotion Link::Credit Link::SocialMedia MediaObject Page Page::Error Page::Landing User)) }
  end

  describe '#model' do
    let(:model) { RailsAdmin.config.models.find { |m| m.abstract_model.model_name == model_name } }

    context 'when model is Banner' do
      let(:model_name) { 'Banner' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be true }
      end
    end

    context 'when model is BrowseEntry' do
      let(:model_name) { 'BrowseEntry' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be true }
      end
    end

    context 'when model is BrowseEntry::FacetEntry' do
      let(:model_name) { 'BrowseEntry::FacetEntry' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be true }
      end
    end

    context 'when model is Collection' do
      let(:model_name) { 'Collection' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be true }
      end
    end

    context 'when model is HeroImage' do
      let(:model_name) { 'HeroImage' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be false }
      end
    end

    context 'when model is Link' do
      let(:model_name) { 'Link' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be false }
      end
    end

    context 'when model is MediaObject' do
      let(:model_name) { 'MediaObject' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be false }
      end
    end

    context 'when model is Page' do
      let(:model_name) { 'Page' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be true }
      end
    end

    context 'when model is Page::Error' do
      let(:model_name) { 'Page::Error' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be true }
      end
    end

    context 'when model is Page::Landing' do
      let(:model_name) { 'Page::Landing' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be true }
      end
    end

    context 'when model is User' do
      let(:model_name) { 'User' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be true }
      end
    end
  end
end
