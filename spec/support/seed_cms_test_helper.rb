module SeedCmsTestHelper
  RSpec.configure do |config|
    config.before(:each) do
      FactoryGirl.create(:collection, :home).publish!
      FactoryGirl.create(:landing_page, :home).publish!
      FactoryGirl.create(:collection, :music).publish!
      FactoryGirl.create(:landing_page, :music_collection).publish!
      FactoryGirl.create(:error_page, :not_found).publish!
      FactoryGirl.create(:error_page, :internal_server_error).publish!
    end
  end
end
