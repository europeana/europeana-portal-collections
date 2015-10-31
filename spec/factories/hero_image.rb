FactoryGirl.define do
  factory :hero_image do
    settings HashWithIndifferentAccess.new(
      attribution_title: 'website', attribution_creator: 'author',
      attribution_institution: 'The Firm', attribution_url: 'http://firm.example.com/',
      text: 'description', brand_opacity: '50', brand_position: 'topleft',
      brand_colour: 'site'
    )
    license 'CC0'
  end
end
