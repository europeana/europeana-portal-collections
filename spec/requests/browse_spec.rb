RSpec.describe 'redirects for the /browse path' do
  it 'redirects GET /en/browse/agents to /en/explore/people' do
    get('/en/browse/agents')
    expect(response).to redirect_to('/en/explore/people')
  end

  it 'redirects GET /en/browse/concepts to /en/explore/topics' do
    get('/en/browse/concepts')
    expect(response).to redirect_to('/en/explore/topics')
  end

  %w(people topics newcontent colours sources).each do |action|
    it "redirects GET /en/browse/#{action} to /en/explore/#{action}" do
      get("/en/browse/#{action}")
      expect(response).to redirect_to("/en/explore/#{action}")
    end
  end
end
