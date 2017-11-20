# frozen_string_literal: true

RSpec.describe 'portal/index.json.jbuilder', :blacklight_config do
  before do
    assign(:response, response)
    assign(:document_list, response.documents)
  end

  let(:api_response) do
    {
      'totalResults': 2_278_183,
      items: api_response_items
    }
  end

  let(:api_response_items) do
    [
      { id: '/abc/123', title: 'Paris in summer' },
      { id: '/abc/124', title: 'Paris in winter' }
    ]
  end

  let(:request_params) { { query: 'paris', rows: 12, start: 1 } }
  let(:response) { Europeana::Blacklight::Response.new(api_response, request_params) }

  let(:json) { JSON.parse(rendered).with_indifferent_access }

  it 'includes total' do
    render

    expect(json[:total]).to be_kind_of(Hash)
    expect(json[:total]).to match(
      value: be_kind_of(Integer),
      formatted: be_kind_of(String)
    )
  end

  it 'includes items' do
    render

    expect(json[:search_results]).to be_kind_of(Array)
    expect(json[:search_results].size).to eq(api_response_items.size)
    api_response_items.each do |item|
      expect(json[:search_results].detect { |result| result[:object_url].include?(item[:id])}).not_to be_nil
    end
  end
end
