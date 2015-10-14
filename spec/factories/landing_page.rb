FactoryGirl.define do
  factory :landing_page, class: Page::Landing do
    hero_image
    slug ''

    trait :home do
      slug ''
    end

    trait :music_channel do
      slug 'channels/music'
    end
  end
end
