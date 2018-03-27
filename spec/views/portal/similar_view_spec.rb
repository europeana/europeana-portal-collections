# frozen_string_literal: true

RSpec.describe 'portal/similar.json.erb' do
  before do
    response = instance_double('Europeana::Blacklight::Response')
    allow(response).to receive(:current_page).and_return(1)
    allow(response).to receive(:limit_value).and_return(4)
    allow(response).to receive(:total_count).and_return(5962)
    assign(:similar, [])
    assign(:response, response)
    render
  end

  subject { JSON.parse(rendered) }

  it 'is valid JSON' do
    expect { subject }.not_to raise_error
  end

  it 'contains pagination' do
    expect(subject).to have_key('page')
    expect(subject).to have_key('per_page')
    expect(subject).to have_key('total')
  end
end
