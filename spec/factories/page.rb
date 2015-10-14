FactoryGirl.define do
  factory :page do
    title 'About the site'
    body '<p>An introduction.</p></p>Everything you need to know.</p>'
    slug 'about'
    hero_image
  end
end
