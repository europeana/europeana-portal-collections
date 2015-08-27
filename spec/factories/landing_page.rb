FactoryGirl.define do
  factory :landing_page do
    hero_image

    trait :music_channel do
      channel { Channel.find_by_key('music') }
    end
  end
end
