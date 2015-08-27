FactoryGirl.define do
  factory :hero_image do
    attribution HashWithIndifferentAccess.new(
      title: 'website', creator: 'author', institution: 'The Firm',
      url: 'http://firm.example.com/', text: 'description'
    )
    brand HashWithIndifferentAccess.new(
      circles_opacity: '50', circles_position: 'topleft', circles_colour: 'site'
    )
    license 'CC0'
  end
end
