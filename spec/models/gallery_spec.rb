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
          expect(gallery.images.detect { |image| image.europeana_record_id == "/123/record#{number}" }).not_to be_blank
        end
      end

      it 'should set image position' do
        gallery.image_portal_urls_text = gallery_image_portal_urls(number: 2)
        gallery.set_images
        gallery.images.reload
        expect(gallery.images.detect { |image| image.europeana_record_id == '/123/record1' }.position).to eq(1)
        expect(gallery.images.detect { |image| image.europeana_record_id == '/123/record2' }.position).to eq(2)
      end

      it 'should delete images for absent URLs' do
        gallery.image_portal_urls_text = gallery_image_portal_urls(number: 8)
        gallery.set_images
        expect(gallery.images.reload.count).to eq(8)
      end

      it 'should set the URL for the images' do
        gallery.image_portal_urls_text = gallery_image_portal_urls(number: 8)
        gallery.set_images
        gallery.images.reload
        expect(gallery.images.size).to eq(8)
        (1..8).each do |number|
          expect(gallery.images.detect { |image| image.europeana_record_id == "/123/record#{number}" }&.url).
            to eq("http://media.example.com/#{number}.jpg")
        end
      end
    end
  end

  describe 'validation' do
    it 'checks format of image URLs' do
      gallery = galleries(:empty)
      gallery.image_portal_urls_text = gallery_image_portal_urls(format: 'http://www.example.com/%{number}')
      expect(gallery).not_to be_valid
      expect(gallery.errors[:image_portal_urls_text]).not_to be_none
    end

    it 'requires 6-48 images' do
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

    it 'prevents > 3 categorisations' do
      topics = (1..4).map do |number|
        Topic.create(label: "Gallery topic #{number}")
      end
      gallery = described_class.new
      gallery.topics = topics[0..2]
      gallery.validate
      expect(gallery.errors[:categorisations]).to be_blank
      gallery.topics.push(topics[3])
      gallery.validate
      expect(gallery.errors[:categorisations]).not_to be_blank
    end
  end

  describe '#image_portal_urls_text' do
    context 'with @image_portal_urls_text' do
      let(:value) { 'urls' }

      before do
        subject.instance_variable_set(:@image_portal_urls_text, value)
      end

      it 'returns @image_portal_urls_text' do
        expect(subject.image_portal_urls_text).to eq(value)
      end
    end

    context 'without @image_portal_urls_text' do
      context 'with attributes[:image_portal_urls]' do
        let(:value) { ['url1', 'url2'] }

        before do
          subject.image_portal_urls = value
        end

        it 'returns joined attributes[:image_portal_urls]' do
          expect(subject.image_portal_urls_text).to eq(value.join("\n\n"))
        end
      end

      context 'without attributes[:image_portal_urls]' do
        context 'with images' do
          let(:image_portal_urls) do
            [gallery_image_portal_url(number: 1), gallery_image_portal_url(number: 2)]
          end

          before do
            image_portal_urls.each do |url|
              subject.images.push(GalleryImage.from_portal_url(url))
            end
          end

          it 'uses image portal URLs' do
            expect(subject.image_portal_urls_text).to eq(image_portal_urls.join("\n\n"))
          end
        end

        context 'without images' do
          it 'returns ""' do
            expect(subject.image_portal_urls_text).to eq('')
          end
        end
      end
    end
  end

  describe '#image_errors' do
    context 'when present' do
      subject { described_class.new(image_errors: { 'url1' => ['err1'], 'url2' => ['err2'] }) }

      it 'is propagated to errors on image_portal_urls_text after initialize' do
        expect(subject.errors[:image_portal_urls_text]).to include('err1')
        expect(subject.errors[:image_portal_urls_text]).to include('err2')
      end
    end
  end
end
