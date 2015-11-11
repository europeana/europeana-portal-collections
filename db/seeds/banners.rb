unless Banner.find_by_key('phase-feedback').present?
  ActiveRecord::Base.transaction do
    Banner.create!(
      key: 'phase-feedback',
      title: 'This is an Alpha release of our new collections search and Music Collection',
      body: 'An Alpha release means that this website is in active development and will be updated regularly. It may sometimes be offline. Your feedback will help us improve our site.',
      link: Link.new(
        url: 'http://insights.hotjar.com/s?siteId=54631&surveyId=2939',
        text: 'Give us your input!'
      )
    ).publish!
  end
end
