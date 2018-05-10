# frozen_string_literal: true

RSpec.describe GalleryDisplayabilityJob do
  let(:gallery) { galleries(:fashion_dresses) }

  before do
    Rails.application.config.x.gallery.validation_mail_to = 'example@europeana.eu'
    allow(Gallery).to receive(:find).with(gallery.id) { gallery }
    allow(Gallery).to receive(:find).with(gallery.id.to_s) { gallery }
    gallery.images.each do |image|
      allow(GalleryImage).to receive(:from_portal_url).with(image.portal_url) { image }
    end
  end

  it 'runs http validation' do
    gallery.images.each do |image|
      expect(image).to receive(:validate_http_image)
    end
    subject.perform(gallery.id)
  end

  it 'runs API validation' do
    gallery.images.each do |image|
      expect(image).to receive(:validate_found_europeana_record_id)
      expect(image).to receive(:validate_europeana_record_web_resource)
    end
    subject.perform(gallery.id)
  end

  context 'when everything is valid' do
    before do
      gallery.images.each do |image|
        allow(image).to receive(:errors) { ActiveModel::Errors.new(image) }
      end
    end

    it 'sets gallery images' do
      expect(gallery).to receive(:set_images).with(gallery.images.map(&:portal_url))
      subject.perform(gallery.id)
    end

    it 'stores no errors on the gallery' do
      subject.perform(gallery.id)
      expect(gallery.reload.image_errors).to be_nil
    end

    it 'sends no email' do
      expect { subject.perform(gallery.id) }.not_to have_enqueued_job(ActionMailer::DeliveryJob)
    end
  end

  context 'when images have errors' do
    before do
      gallery.images.each do |image|
        allow(image).to receive(:errors) {
          ActiveModel::Errors.new(image).tap do |am_errors|
            am_errors.add(:url, 'Invalid')
          end
        }
      end
    end

    it 'does not set gallery images' do
      expect(gallery).not_to receive(:set_images).with(gallery.images.map(&:portal_url))
      subject.perform(gallery.id)
    end

    it 'stores the errors on the gallery' do
      subject.perform(gallery.id)
      expect(gallery.reload.image_errors).not_to be_nil
    end

    it 'sends an email' do
      expect { subject.perform(gallery.id) }.to have_enqueued_job(ActionMailer::DeliveryJob)
    end
  end
end
