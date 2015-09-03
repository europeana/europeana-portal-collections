FactoryGirl.define do
  factory :channel do
    sequence(:key) { |n| "key (#{n})" }
    api_params 'qf=what:ever'

    trait :with_landing_page do
      landing_page
    end

    trait :music do
      key 'music'
      api_params 'qf=what:music'
    end
  end
end
