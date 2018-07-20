# frozen_string_literal: true

RSpec.shared_context 'Gallery Image portal URLs', :gallery_image_portal_urls do
  def gallery_image_portal_url_format
    'https://www.europeana.eu/portal/record/123/record%{number}.html?view=http%%3A%%2F%%2Fmedia.example.com%%2F%{number}.jpg'
  end

  def gallery_image_portal_url(number: 1, format: gallery_image_portal_url_format)
    format(format, number: number)
  end

  def gallery_image_portal_urls(number: 10, format: gallery_image_portal_url_format)
    (1..number).map { |n| gallery_image_portal_url(number: n, format: format) }.join(' ')
  end
end
