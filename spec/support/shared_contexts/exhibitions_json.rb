# frozen_string_literal: true

RSpec.shared_context 'Exhibitions JSON', :exhibitions_json do
  let(:exhibitions_url) { 'https://europeana.eu' }
  let(:configured_exhibitions_host) { exhibitions_url }
  let(:lang_code) { 'en' }
  let(:exhibition_slug) { 'test-exhibition'}
  let(:exhibitions_json_url) { %r{\A#{configured_exhibitions_host}/portal/#{lang_code}/exhibitions/#{exhibition_slug}.json\z} }
  let(:exhibition_response_status) { 200 }
  let(:exhibition_response_body) { exhibtions_json_response }

  before do
    Rails.application.config.x.exhibitions.host = configured_exhibitions_host

    stub_request(:get, exhibitions_json_url).
      to_return(status: exhibition_response_status,
                body: exhibition_response_body,
                headers: { 'Content-Type' => 'application/ld+json' })
  end

  def an_exhibitions_json_request_for(slug)
    a_request(:get, "#{configured_exhibitions_host}/portal/#{lang_code}/exhibitions/#{slug}.json")
  end

  def exhibtions_json_response
    {
      url: "#{configured_exhibitions_host}/portal/#{lang_code}/exhibitions/test-exhibition",
      credit_image: 'https://fake-cdn/exhibitions/images/versions/abc/logo.jpeg',
      description: 'Fake description',
      full_image: 'https://fake-cdn/exhibitions/images/versions/abc/image.jpeg',
      card_image: 'https://fake-cdn/exhibitions/images/versions/abc/image.jpeg',
      card_text: 'Fake description',
      labels: ['Art', 'Technology'],
      lang_code: 'en',
      title: 'Test Exhibition',
      slug: 'test-exhibition',
      depth: 2
    }.to_json
  end
end
