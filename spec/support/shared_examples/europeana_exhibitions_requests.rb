# frozen_string_literal: true

shared_examples 'an exhibitions JSON request' do
  it 'queries exhibitions for a JSON representation' do
    expect(an_exhibitions_json_request_for(exhibition_slug)).
      to have_been_made
  end
end

shared_examples 'no exhibitions JSON request' do
  it 'queries exhibitions for a JSON representation' do
    expect(an_exhibitions_json_request_for(exhibition_slug)).
      to_not have_been_made
  end
end
