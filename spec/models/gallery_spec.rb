# frozen_string_literal: true
RSpec.describe Gallery do
  def gallery_image_portal_urls(number: 10, format: 'http://www.europeana.eu/portal/record/pic/%{n}.html')
    (1..number).map { |n| format(format, n: n) }.join(' ')
  end

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

  it 'should translate title' do
    expect(described_class.translated_attribute_names).to include(:title)
  end

  it 'should enforce unique titles' do
    g1 = Gallery.create(title: 'Stuff', image_portal_urls: gallery_image_portal_urls)
    g2 = Gallery.create(title: 'Stuff', image_portal_urls: gallery_image_portal_urls)
    g3 = Gallery.create(title: 'Stuff', image_portal_urls: gallery_image_portal_urls)
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

  describe '#image_portal_urls' do
    it 'should return a new line-separated list of gallery image record URLs' do
      expect(galleries(:fashion_dresses).image_portal_urls).to eq("http://www.europeana.eu/portal/record/dresses/1.html\n\nhttp://www.europeana.eu/portal/record/dresses/2.html")
    end
  end

  describe '#set_images_from_portal_urls' do
    context '(on create)' do
      let(:gallery) { Gallery.new(title: 'Pictures', image_portal_urls: gallery_image_portal_urls(number: 10)) }

      it 'should create images for new URLs' do
        gallery.save
        expect(gallery.images.count).to eq(10)
        gallery.images.reload
        (1..10).each do |number|
          expect(gallery.images.detect { |image| image.europeana_record_id == "/pic/#{number}" }).not_to be_blank
        end
      end

      it 'should set image position' do
        gallery.save
        gallery.images.reload
        expect(gallery.images.detect { |image| image.europeana_record_id == '/pic/1' }.position).to eq(1)
        expect(gallery.images.detect { |image| image.europeana_record_id == '/pic/2' }.position).to eq(2)
      end
    end

    context '(on update)' do
      let(:gallery) { Gallery.create(title: 'Pictures', image_portal_urls: gallery_image_portal_urls(number: 10)) }

      it 'should create images for new URLs' do
        gallery.image_portal_urls = gallery_image_portal_urls(number: 20)
        gallery.save
        gallery.images.reload
        (1..20).each do |number|
          expect(gallery.images.detect { |image| image.europeana_record_id == "/pic/#{number}" }).not_to be_blank
        end
      end

      it 'should set image position' do
        gallery.images.find_by_europeana_record_id('/pic/1').update_attributes(position: 2)
        gallery.images.find_by_europeana_record_id('/pic/2').update_attributes(position: 1)
        gallery.image_portal_urls = gallery_image_portal_urls(number: 20)
        gallery.save
        gallery.images.reload
        expect(gallery.images.detect { |image| image.europeana_record_id == '/pic/1' }.position).to eq(1)
        expect(gallery.images.detect { |image| image.europeana_record_id == '/pic/2' }.position).to eq(2)
      end

      it 'should delete images for absent URLs' do
        gallery.image_portal_urls = gallery_image_portal_urls(number: 8)
        gallery.save
        expect(gallery.images.reload.count).to eq(8)
      end
    end
  end

  it 'should validate image URLs before saving' do
    gallery = galleries(:empty)
    gallery.image_portal_urls = gallery_image_portal_urls(format: 'http://www.example.com/%{n}')
    expect(gallery).not_to be_valid
    expect(gallery.errors[:image_portal_urls]).not_to be_none
  end

  it 'should require 6-24 images' do
    gallery = galleries(:empty)
    (1..30).each do |number|
      gallery.image_portal_urls = gallery_image_portal_urls(number: number)
      if number < 6 || number > 24
        expect(gallery).not_to be_valid
        expect(gallery.errors[:image_portal_urls]).not_to be_none
      else
        expect(gallery).to be_valid
      end
    end
  end
end
