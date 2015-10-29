FactoryGirl.define do
  factory :error_page, class: Page::Error do
    http_code 400

    trait :not_found do
      http_code 404
    end

    trait :internal_server_error do
      http_code 500
    end
  end
end
