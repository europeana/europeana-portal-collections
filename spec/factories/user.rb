FactoryGirl.define do
  factory :user do
    email 'user@example.com'
    password 'secret!!'
    role 'user'

    trait :admin do
      role 'admin'
    end

    trait :guest do
      role ''
    end
  end
end
