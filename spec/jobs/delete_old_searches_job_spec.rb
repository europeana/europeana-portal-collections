RSpec.describe DeleteOldSearchesJob do
  it 'deletes searches older than one day' do
    expired_time = 2.days.ago
    old_search = Search.create(created_at: expired_time, updated_at: expired_time)
    expect { subject.perform }.to change { Search.find_by_id(old_search.id) }.to(nil)
  end
end
