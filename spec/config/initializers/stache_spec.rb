# frozen_string_literal: true

describe Stache, 'configuration' do
  it 'caches templates in memory' do
    expect(Stache.template_cache.class).to eq(ActiveSupport::Cache::MemoryStore)
  end
end
