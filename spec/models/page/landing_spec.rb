# frozen_string_literal: true

require 'models/concerns/is_permissionable_examples'
RSpec.describe Page::Landing do
  it_behaves_like 'permissionable'

  it { is_expected.to belong_to(:hero_image) }
  it { is_expected.to belong_to(:collection) }
  it { is_expected.to have_many(:credits) }
  it { is_expected.to have_many(:social_media) }
  it { is_expected.to have_many(:promotions) }

  it { is_expected.to accept_nested_attributes_for(:hero_image) }
  it { is_expected.to accept_nested_attributes_for(:credits) }
  it { is_expected.to accept_nested_attributes_for(:social_media) }
  it { is_expected.to accept_nested_attributes_for(:promotions) }
  it { is_expected.to accept_nested_attributes_for(:browse_entries) }

  it { is_expected.to respond_to(:newsletter_url) }

  it { is_expected.to delegate_method(:file).to(:hero_image).with_prefix(true) }

  it { is_expected.to validate_inclusion_of(:layout_type).in_array(%w(default browse)) }
  it { is_expected.to validate_presence_of(:collection) }
  it { is_expected.to validate_uniqueness_of(:collection) }

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(PaperTrail::Model::InstanceMethods) }
  end

  describe '.home' do
    it 'should return the homepage' do
      expect(described_class.home).to eq(pages(:home))
    end
  end

  describe 'creation' do
    context 'when it is the all collection' do
      it 'should set the slug' do
        subject.collection = collections(:all)
        subject.run_callbacks :create
        expect(subject.slug).to eq('')
      end
    end

    context 'when it is a thematic collection' do
      it 'should set the slug' do
        subject.collection = collections(:music)
        subject.run_callbacks :create
        expect(subject.slug).to eq('collections/music')
      end
    end
  end

  describe '#set_slug' do
    let(:page) { pages(:music_collection) }
    context 'when the slug is empty' do
      before do
        page.slug = nil
      end
      it 'should set the slug' do
        page.send(:set_slug)
        expect(page.slug).to eq('collections/music')
      end
    end
  end

  describe '#og_image' do
    it 'should return an image from either the first promo tile or the hero image' do
      expect(subject).to receive(:og_image_from_promo) { false }
      expect(subject).to receive(:og_image_from_hero) { 'the hero image' }
      expect(subject.og_image).to eq('the hero image')
    end
  end

  describe '#og_image_from_promo' do
    context 'when the page uses the default layout' do
      let(:page) { pages(:music_collection) }

      it 'should always be nil' do
        expect(page.send(:og_image_from_promo)).to be_nil
      end
    end

    context 'when the page uses the browse layout' do
      let(:page) { pages(:fashion_collection) }

      it 'should return the image from the promo tile with position 0' do
        expect(page.send(:og_image_from_promo)).to eq(media_objects(:fake_file).file.url)
      end
    end
  end
end
