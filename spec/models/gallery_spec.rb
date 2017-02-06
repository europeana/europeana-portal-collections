# frozen_string_literal: true
RSpec.describe Gallery do
  it { is_expected.to have_many(:images).inverse_of(:gallery).dependent(:destroy) }
  it { is_expected.to have_and_belong_to_many(:collections).inverse_of(:galleries) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_most(60) }
  it { is_expected.to validate_length_of(:description).is_at_most(280) }
  it { is_expected.to be_versioned }
  it { is_expected.to accept_nested_attributes_for(:images).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:translations).allow_destroy(true) }

  it 'should have publication states' do
    expect(described_class).to include(HasPublicationStates)
  end

  it 'should translate title' do
    expect(described_class.translated_attribute_names).to include(:title)
  end

  it 'should enforce unique titles' do
    g1 = Gallery.create(title: 'Stuff')
    g2 = Gallery.create(title: 'Stuff')
    g3 = Gallery.create(title: 'Stuff')
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
      let(:gallery) { Gallery.new(title: 'Nice', image_portal_urls: 'http://www.europeana.eu/portal/record/nice/1.html http://www.europeana.eu/portal/record/nice/2.html') }

      it 'should create images for new URLs' do
        gallery.save
        expect(gallery.images.count).to eq(2)
        expect(gallery.images.reload.detect { |image| image.europeana_record_id == '/nice/1' }).not_to be_blank
        expect(gallery.images.reload.detect { |image| image.europeana_record_id == '/nice/2' }).not_to be_blank
      end

      it 'should set image position' do
        gallery.save
        expect(gallery.images.reload.detect { |image| image.europeana_record_id == '/nice/1' }.position).to eq(1)
        expect(gallery.images.reload.detect { |image| image.europeana_record_id == '/nice/2' }.position).to eq(2)
      end
    end

    context '(on update)' do
      let(:gallery) { galleries(:fashion_dresses) }

      it 'should create images for new URLs' do
        gallery.image_portal_urls = 'http://www.europeana.eu/portal/record/nice/1.html'
        gallery.save
        expect(gallery.images.reload.detect { |image| image.europeana_record_id == '/nice/1' }).not_to be_blank
      end

      it 'should set image position' do
        gallery.image_portal_urls = 'http://www.europeana.eu/portal/record/dresses/2.html http://www.europeana.eu/portal/record/nice/1.html'
        gallery.save
        expect(gallery.images.reload.detect { |image| image.europeana_record_id == '/dresses/2' }.position).to eq(1)
        expect(gallery.images.reload.detect { |image| image.europeana_record_id == '/nice/1' }.position).to eq(2)
      end

      it 'should delete images for absent URLs' do
        gallery.image_portal_urls = 'http://www.europeana.eu/portal/record/nice/1.html'
        gallery.save
        expect(gallery.images.reload.count).to eq(1)
      end
    end
  end

  it 'should validate image URLs before saving' do
    gallery = galleries(:empty)
    expect(gallery).to be_valid
    gallery.image_portal_urls = 'http://www.google.co.uk'
    expect(gallery).not_to be_valid
    expect(gallery.errors[:image_portal_urls]).not_to be_none
  end
end
