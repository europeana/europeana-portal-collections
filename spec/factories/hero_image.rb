FactoryGirl.define do
  factory :hero_image do
    brand HashWithIndifferentAccess.new(
      circles_opacity: '50', circles_position: 'topleft', circles_colour: 'site'
    )
  end
end
