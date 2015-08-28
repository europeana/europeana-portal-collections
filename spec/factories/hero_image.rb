FactoryGirl.define do
  factory :hero_image do
    attribution HashWithIndifferentAccess.new(
      title: 'website', creator: 'author', institution: 'The Firm',
      url: 'http://firm.example.com/', text: 'description'
    )
    brand HashWithIndifferentAccess.new(
      opacity: '50', position: 'topleft', colour: 'site'
    )
    license 'CC0'
  end
end
