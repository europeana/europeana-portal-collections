# frozen_string_literal: true
RSpec.describe 'entities/show.html.mustache' do
  let(:body_cache_key) { '/en/entities/agent/base/1234' }

  before(:each) do
    allow(view).to receive(:body_cache_key).and_return(body_cache_key)
    render
  end

  subject { rendered }

  it 'should have meta description' do
    expect(subject).to have_selector('meta[name="description"]', visible: false)
  end

  it 'should have meta HandheldFriendly', skip: true do
    expect(subject).to have_selector('meta[name="HandheldFriendly"]', visible: false)
  end
end
