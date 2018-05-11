# frozen_string_literal: true

RSpec.describe GalleryDisplayabilityMailer, :gallery_image_portal_urls do
  describe '#post' do
    let(:args) { { gallery: gallery, image_errors: image_errors } }
    let(:gallery) { Gallery.create(title: 'Broken gallery', image_portal_urls_text: image_portal_urls) }
    let(:image_portal_urls) { gallery_image_portal_urls }
    let(:image_errors) do
      gallery.image_portal_urls.each_with_object({}) do |portal_url, memo|
        memo[portal_url] = ['This one broke!']
      end
    end
    let(:mail) { described_class.post(args) }

    before(:each) do
      Rails.application.config.x.gallery.validation_mail_to = recipient
    end

    context 'without recipient configured' do
      let(:recipient) { nil }

      it 'fails' do
        expect { mail.deliver_now }.to raise_exception(ApplicationMailer::Errors::NoRecipient)
      end
    end

    context 'with recipient configured' do
      let(:recipient) { 'editor@example.org' }

      it 'renders the headers' do
        expect(mail.subject).to eq('Gallery Displayability')
        expect(mail.to).to eq([recipient])
        expect(mail.from).to eq([ApplicationMailer.default[:from]])
      end

      describe 'mail body' do
        subject { mail.body.encoded }

        it 'includes gallery title' do
          expect(subject).to include("Europeana gallery: #{gallery.title}")
        end

        it 'includes public gallery URL' do
          expect(subject).to include("URL: http://localhost/en/explore/galleries/#{gallery.slug}")
        end

        it 'includes each error' do
          image_errors.each_pair do |portal_url, errors|
            errors.each do |error|
              expect(subject).to include("#{portal_url}\r\n    * #{error}")
            end
          end
        end

        it 'includes CMS URL' do
          expect(subject).to include("CMS link: http://localhost/en/cms/gallery/#{gallery.id}/edit")
        end
      end
    end
  end
end
