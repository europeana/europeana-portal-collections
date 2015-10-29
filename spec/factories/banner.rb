FactoryGirl.define do
  factory :banner do
    sequence(:key) { |n| "key (#{n})" }
    title 'Banner title'
    link
  end
end
