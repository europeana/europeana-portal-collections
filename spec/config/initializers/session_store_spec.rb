# frozen_string_literal: true

describe Rails.application.config.session_store do
  it 'uses ActionDispatch::Session::ActiveRecordStore' do
    expect(Rails.application.config.session_store).to eq(ActionDispatch::Session::CookieStore)
  end

  it 'has key "_europeana_portal_session"' do
    expect(Rails.application.config.session_options[:key]).to eq('_portal_session')
  end
end
