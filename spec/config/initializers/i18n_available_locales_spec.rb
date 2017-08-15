# frozen_string_literal: true

RSpec.describe 'I18n available locales initializer' do
  subject { Rails.application.config.i18n.available_locales }

  def read_initializer
    @file_path ||= File.expand_path('../../../../config/initializers/i18n_available_locales.rb', __FILE__)
    eval(File.open(File.expand_path(@file_path)).read)
  end

  context "when ENV['I18N_ADDITIONAL_LOCALES'] is set" do
    let(:env_var) { 'cs' }
    let(:default_locales) { %i(en de) }

    before(:all) do
      @additional_locales_was = ENV['I18N_ADDITIONAL_LOCALES'].dup
      @available_locales_was = Rails.application.config.i18n.available_locales.dup
    end

    before(:each) do
      ENV['I18N_ADDITIONAL_LOCALES'] = env_var.dup
      Rails.application.config.i18n.available_locales = default_locales.dup
    end

    after(:all) do
      ENV['I18N_ADDITIONAL_LOCALES'] = @additional_locales_was
      Rails.application.config.i18n.available_locales = @available_locales_was
    end

    it 'adds locales to I18n' do |example|
      read_initializer
      expect(subject).to include(:cs)
    end

    it 'sorts locales' do
      read_initializer
      expect(subject.first).to eq(:cs)
      expect(subject.last).to eq(:en)
    end

    context 'when there are duplicates' do
      let(:env_var) { 'en,de' }
      it 'fails' do
        expect { read_initializer }.to raise_error('Duplicate locales detected: de,en')
      end
    end
  end
end
