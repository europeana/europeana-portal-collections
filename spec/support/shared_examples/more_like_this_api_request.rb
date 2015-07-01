shared_examples 'a more like this api request' do
  it 'queries the API for the named record' do
    expect(an_api_record_request_for(record_id))
      .to have_been_made.at_least_once
  end

  it 'does not query the API for the record hierarchy' do
    expect(an_api_hierarchy_request_for(record_id))
      .not_to have_been_made
  end

  it 'queries the API for MLT records' do
    expect(an_api_search_request
      .with(query: hash_including(query: /NOT europeana_id:"#{record_id}"/)))
      .to have_been_made.at_least_once
  end
end
