# frozen_string_literal: true

RSpec.shared_context 'Gallery Image portal URLs', :gallery_image_portal_urls do
  def gallery_image_portal_urls(number: 10, format: 'http://www.europeana.eu/portal/record/sample/record%{n}.html?view=http://media.example.com/%{n}.jpg')
    (1..number).map { |n| format(format, n: n) }.join(' ')
  end
end
