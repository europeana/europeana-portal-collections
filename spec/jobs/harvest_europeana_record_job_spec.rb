RSpec.describe HarvestEuropeanaRecordJob  do
  it 'should send a request to the Record API' do
    record = europeana_records(:bird_picture)
    described_class.perform_now(record.id)
    expect(an_api_record_request_for('/bird/picture')).to have_been_made
  end

  it 'should write the metadata from the response to the db' do
    record = europeana_records(:bird_picture)
    expect(record.metadata).to be_nil
    described_class.perform_now(record.id)
    expect(record.reload.metadata).to be_a(Hash)
    expect(record.metadata['about']).to eq('/bird/picture')
  end
end
