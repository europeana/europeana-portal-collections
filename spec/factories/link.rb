FactoryGirl.define do
  factory :link do
    url 'http://www.example.com'
    text 'Example site'

    factory :promotion_link, class: Link::Promotion do
    end
  end
end
