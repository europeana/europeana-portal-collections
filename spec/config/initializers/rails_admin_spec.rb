RSpec.describe RailsAdmin.config do
  describe '#included_models' do
    subject { RailsAdmin.config.included_models }
    it { is_expected.to eq(%w(Channel HeroImage LandingPage Link LinkSet MediaObject User)) }
  end

  describe '#model' do
    let(:model) { RailsAdmin.config.models.find { |m| m.abstract_model.model_name == model_name } }

    context 'when model is Channel' do
      let(:model_name) { 'Channel' }
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

    context 'when model is LandingPage' do
      let(:model_name) { 'LandingPage' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be true }
      end
    end

    context 'when model is Link' do
      let(:model_name) { 'Link' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be false }
      end
    end

    context 'when model is LinkSet' do
      let(:model_name) { 'LinkSet' }
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

    context 'when model is User' do
      let(:model_name) { 'User' }
      describe '.visible' do
        subject { model.visible }
        it { is_expected.to be true }
      end
    end
  end
end
