RSpec.describe 'portal/similar.json.erb' do
  it 'is valid JSON' do
    assign(:similar, [])
    render
    expect { JSON.parse(rendered) }.not_to raise_error
  end
end
