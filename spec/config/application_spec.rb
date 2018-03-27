# frozen_string_literal: true

RSpec.describe Rails.application.config do
  it 'should enable i18n fallbacks' do
    expect(I18n.fallbacks[:nl]).to eq(%i(nl en))
  end
end
