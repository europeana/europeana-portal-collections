FactoryGirl.define do
  factory :landing_page, class: Page::Landing do
    hero_image
    slug 'landing'

    trait :home do
      slug ''
      title 'Home'
    end

    trait :music_collection do
      slug 'collections/music'
      title 'Europeana Music'
      body 'About music'
    end
  end
end
