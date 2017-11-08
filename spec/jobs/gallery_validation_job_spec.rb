# frozen_string_literal: true

RSpec.describe GalleryValidationJob do
  include_context 'Gallery Image request'

  let(:url1) { gallery_images(:fashion_dresses_image1).url }
  let(:url2) { gallery_images(:fashion_dresses_image2).url }

  def provider_response(**options)
    content_type = options[:content_type] || 'image/jpeg'
    code = options[:code] || 200
    double('provider_response', code: code, headers: { content_type: content_type })
  end

  before do
    Rails.application.config.x.gallery_validation_mail_to = 'example@europeana.eu'
  end

  context 'when everything is valid' do
    it 'loads all the images for the gallery and makes sure they are valid' do
      expect(RestClient).to receive(:get).with(url1).once.and_return(provider_response)
      expect(RestClient).to receive(:get).with(url2).once.and_return(provider_response)
      expect { subject.perform(galleries(:fashion_dresses).id) }.not_to have_enqueued_job(ActionMailer::DeliveryJob)
      expect(an_api_search_request).to have_been_made.at_least_once
    end
  end

  context 'when a record can NOT be found' do
    let(:gallery_image_search_api_response_options) { { item: false } }
    it 'sends an email saying the record may have been deleted' do
      expect(RestClient).to_not receive(:get).with(url1)
      expect(RestClient).to_not receive(:get).with(url2)
      expect { subject.perform(galleries(:fashion_dresses).id) }.to have_enqueued_job(ActionMailer::DeliveryJob)
      expect(an_api_search_request).to have_been_made.at_least_once
    end
  end

  context 'when an image can NOT be found' do
    let(:gallery_image_search_api_response_options) { { edm_is_shown_by: false } }
    it 'sends an email saying the image is not valid' do
      expect(RestClient).to receive(:get).with(url1).once.and_return(provider_response)
      expect(RestClient).to receive(:get).with(url2).once.and_return(provider_response(code: 500))
      expect { subject.perform(galleries(:fashion_dresses).id) }.to have_enqueued_job(ActionMailer::DeliveryJob)
      expect(an_api_search_request).to have_been_made.at_least_once
    end
  end

  context 'when an image is NOT a valid image' do
    it 'sends an email saying the image is not valid' do
      expect(RestClient).to receive(:get).with(url1).once.and_return(provider_response)
      expect(RestClient).to receive(:get).with(url2).once.and_return(provider_response(content_type: 'application/pdf'))
      expect { subject.perform(galleries(:fashion_dresses).id) }.to have_enqueued_job(ActionMailer::DeliveryJob)
      expect(an_api_search_request).to have_been_made.at_least_once
    end
  end
end
