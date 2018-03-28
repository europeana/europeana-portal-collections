# frozen_string_literal: true

RSpec.describe 'requests for paths without extension' do
  %w(/en/explore/colours /en/explore/topics /en/explore/people /en/explore/sources /en/explore/newcontent /en/about).each do |path|
    it "redirects GET #{path} to #{path}.html" do
      get(path)
      expect(response).to redirect_to("#{path}.html")
    end
  end
end
