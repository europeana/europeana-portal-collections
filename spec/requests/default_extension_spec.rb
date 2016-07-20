RSpec.describe 'requests for paths without extension' do
  %w(/en/browse/colours /en/browse/topics /en/browse/people /en/browse/sources /en/browse/newcontent /en/about).each do |path|
    it "redirects GET #{path} to #{path}.html" do
      get(path)
      expect(response).to redirect_to("#{path}.html")
    end
  end
end
