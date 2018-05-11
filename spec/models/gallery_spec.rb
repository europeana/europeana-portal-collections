# frozen_string_literal: true

require 'models/concerns/is_permissionable_examples'

RSpec.describe Gallery, :gallery_image_portal_urls, :gallery_image_request do
  it 'includes Annotations' do
    expect(described_class).to include(Gallery::Annotations)
  end

  it_behaves_like 'permissionable'

  it { is_expected.to have_many(:images).inverse_of(:gallery).dependent(:destroy) }
  it { is_expected.to have_many(:topics).through(:categorisations) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_most(60) }
  it { is_expected.to validate_length_of(:description).is_at_most(280) }
  it { is_expected.to be_versioned }
  it { is_expected.to accept_nested_attributes_for(:images).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:translations).allow_destroy(true) }

  it 'should have publication states' do
    expect(described_class).to include(HasPublicationStates)
  end

  it 'should be categorisable' do
    expect(described_class).to include(IsCategorisable)
  end

  context 'publishing' do
    let(:stubbed_now) { DateTime.now }
    let(:gallery) { galleries(:draft) }

    before do
      stubbed_now # Calling to set this, and avoid infinite recursion
      allow(DateTime).to receive(:now) { stubbed_now }
      allow(gallery).to receive(:validate_number_of_image_portal_urls) { true }
      allow(gallery).to receive(:validate_image_portal_urls) { true }
      allow(::PaperTrail).to receive(:whodunnit) { users(:user) }
    end

    context 'without enough images' do
      it 'should fail' do
        expect { gallery.publish! }.to raise_exception(AASM::InvalidTransition)
        expect(gallery).not_to be_published
      end
    end

    context 'with enough images' do
      before do
        6.times do
          gallery.images.push(gallery_images(:fashion_dresses_image1).dup)
        end
      end

      it 'should set the publisher and published_at date when first publishing' do
        expect(gallery).to be_valid
        gallery.publish!
        expect(gallery.published_at).to eq(stubbed_now)
        expect(gallery.publisher).to eq(users(:user))
      end

      it 'should NOT modify the publisher and published_at date when un and re-publishing' do
        gallery.publish!
        gallery.unpublish!
        allow(DateTime).to receive(:now) { stubbed_now + 1.hour }
        allow(::PaperTrail).to receive(:whodunnit) { users(:admin) }
        gallery.publish!
        expect(gallery.published_at).to eq(stubbed_now)
        expect(gallery.publisher).to eq(users(:user))
      end
    end
  end

  it 'should translate title' do
    expect(described_class.translated_attribute_names).to include(:title)
  end

  it 'should enforce unique titles' do
    g1 = Gallery.create!(title: 'Stuff', image_portal_urls_text: gallery_image_portal_urls)
    g2 = Gallery.create!(title: 'Stuff', image_portal_urls_text: gallery_image_portal_urls)
    g3 = Gallery.create!(title: 'Stuff', image_portal_urls_text: gallery_image_portal_urls)
    expect(g1.reload.title).to eq('Stuff')
    expect(g2.reload.title).to eq('Stuff 1')
    expect(g3.reload.title).to eq('Stuff 2')
  end

  it 'should translate description' do
    expect(described_class.translated_attribute_names).to include(:description)
  end

  describe '#to_param' do
    it 'should return the slug' do
      gallery = Gallery.new(title: 'Pianos', slug: 'pianos')
      expect(gallery.to_param).to eq('pianos')
    end
  end

  describe '#set_images' do
    context 'when creating' do
      let(:gallery) { Gallery.new(title: 'Pictures', image_portal_urls_text: gallery_image_portal_urls(number: 10)) }

      it 'is not called' do
        expect(gallery).not_to receive(:set_images)
        gallery.save
        expect(gallery.images.reload.count).to be_zero
      end
    end

    context 'when updating' do
      let(:gallery) { Gallery.create(title: 'Pictures', image_portal_urls_text: gallery_image_portal_urls(number: 10)) }

      it 'is not called' do
        expect(gallery).not_to receive(:set_images)
        gallery.image_portal_urls_text = gallery_image_portal_urls(number: 20)
        gallery.save
        expect(gallery.images.reload.count).to be_zero
      end
    end

    context 'when called' do
      let(:gallery) { Gallery.create(title: 'Pictures', image_portal_urls_text: gallery_image_portal_urls(number: 10)) }

      it 'should create images for new URLs' do
        gallery.image_portal_urls_text = gallery_image_portal_urls(number: 20)
        gallery.set_images
        gallery.images.reload
        (1..20).each do |number|
          expect(gallery.images.detect { |image| image.europeana_record_id == "/sample/record#{number}" }).not_to be_blank
        end
      end

      it 'should set image position' do
        gallery.image_portal_urls_text = gallery_image_portal_urls(number: 2)
        gallery.set_images
        gallery.images.reload
        expect(gallery.images.detect { |image| image.europeana_record_id == '/sample/record1' }.position).to eq(1)
        expect(gallery.images.detect { |image| image.europeana_record_id == '/sample/record2' }.position).to eq(2)
      end

      it 'should delete images for absent URLs' do
        gallery.image_portal_urls_text = gallery_image_portal_urls(number: 8)
        gallery.set_images
        expect(gallery.images.reload.count).to eq(8)
      end

      it 'should set the url for the images' do
        gallery.image_portal_urls_text = gallery_image_portal_urls(number: 8)
        gallery.set_images
        gallery.images.reload
        expect(gallery.images.detect { |image| image.europeana_record_id == '/sample/record1' }.url).to eq('http://media.example.com/1.jpg')
        expect(gallery.images.detect { |image| image.europeana_record_id == '/sample/record2' }.url).to eq('http://media.example.com/2.jpg')
      end
    end
  end

  it 'should validate image URLs before saving' do
    gallery = galleries(:empty)
    gallery.image_portal_urls_text = gallery_image_portal_urls(format: 'http://www.example.com/%{n}')
    expect(gallery).not_to be_valid
    expect(gallery.errors[:image_portal_urls_text]).not_to be_none
  end

  it 'should require 6-48 images' do
    gallery = galleries(:empty)
    (1..50).each do |number|
      gallery.image_portal_urls_text = gallery_image_portal_urls(number: number)
      if number < 6 || number > 48
        expect(gallery).not_to be_valid
        expect(gallery.errors[:image_portal_urls_text]).not_to be_none
      else
        expect(gallery).to be_valid
      end
    end
  end

#   describe 'per-image API response validation' do
#     context 'when image_portal_urls has other errors' do
#       it 'is skipped' do
#         gallery = Gallery.new
#         gallery.valid?
#         expect(gallery.errors[:image_portal_urls]).not_to be_none
#         expect(an_api_search_request).not_to have_been_made
#       end
#     end

#     context 'when image_portal_urls has no other errors' do
#       it 'is performed' do
#         gallery = galleries(:empty)
#         gallery.image_portal_urls_text = gallery_image_portal_urls
#         expect(gallery).to be_valid
#         expect(an_api_search_request).to have_been_made.once
#       end

#       context 'when images have no item in API response' do
#         let(:gallery_image_search_api_response_options) { { item: false } }
#         it 'is invalid' do
#           gallery = galleries(:empty)
#           gallery.image_portal_urls_text = gallery_image_portal_urls
#           expect(gallery).not_to be_valid
#           expect(gallery.errors[:image_portal_urls]).not_to be_none
#           expect(gallery.errors[:image_portal_urls]).to include(match('item not found by the API'))
#         end
#       end

#       context 'when items in API response have no edm:isShownBy' do
#         let(:gallery_image_search_api_response_options) { { edm_is_shown_by: false } }
#         it 'is invalid' do
#           gallery = galleries(:empty)
#           gallery.image_portal_urls_text = gallery_image_portal_urls
#           expect(gallery).not_to be_valid
#           expect(gallery.errors[:image_portal_urls]).not_to be_none
#           expect(gallery.errors[:image_portal_urls]).to include(match('item has no edm:isShownBy'))
#         end
#       end
#     end
#   end
end
