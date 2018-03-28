# frozen_string_literal: true

describe 'assets initializer' do
  subject { Rails.application.config.assets }

  it 'sets assets version' do
    expect(subject.version).not_to be_nil
  end

  it 'prevents precompile of non-JS/CSS assets' do
    expect(subject.precompile).not_to include(Sprockets::Railtie::LOOSE_APP_ASSETS)
  end
end
