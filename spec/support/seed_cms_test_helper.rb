module SeedCmsTestHelper
  RSpec.configure do |config|
    config.before(:each) do
      FactoryGirl.create(:channel, :home).publish!
      FactoryGirl.create(:landing_page, :home).publish!
      FactoryGirl.create(:channel, :music).publish!
      FactoryGirl.create(:landing_page, :music_channel).publish!
      FactoryGirl.create(:error_page, :not_found).publish!
    end
  end
end
