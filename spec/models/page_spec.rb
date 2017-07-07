# frozen_string_literal: true

RSpec.describe Page do
  it { is_expected.to belong_to(:banner).inverse_of(:pages) }
  it { is_expected.to belong_to(:hero_image).inverse_of(:page) }
  it { is_expected.to have_many(:element_groups).inverse_of(:page).dependent(:destroy) }
  it { is_expected.to have_many(:elements).through(:element_groups).inverse_of(:page) }
  it { is_expected.to have_many(:browse_entry_groups).dependent(:destroy) }
  it { is_expected.to have_many(:browse_entries).through(:browse_entry_groups) }
  it { is_expected.to validate_uniqueness_of(:slug) }

  it { is_expected.to accept_nested_attributes_for(:hero_image) }
  it { is_expected.to accept_nested_attributes_for(:element_groups) }
  it { is_expected.to accept_nested_attributes_for(:browse_entry_groups) }

  describe 'browse entry group size validation' do
    subject { pages(:about).tap { |page| page.browse_entry_groups = browse_entry_groups } }

    let(:topic_group_of_3) do
      BrowseEntryGroup.new(title: 'topic', browse_entries: [
        browse_entries(:cinema_topic), browse_entries(:music_topic), browse_entries(:harp_topic)
      ])
    end
    let(:topic_group_of_6) do
      BrowseEntryGroup.new(title: 'topic', browse_entries: topic_group_of_3.browse_entries + [
        browse_entries(:manuscripts_topic), browse_entries(:books_topic), browse_entries(:paintings_topic)
      ])
    end
    let(:period_group_of_3) do
      BrowseEntryGroup.new(title: 'period', browse_entries: [
        browse_entries(:century_16_period), browse_entries(:century_17_period), browse_entries(:century_18_period)
      ])
    end
    let(:period_group_of_6) do
      BrowseEntryGroup.new(title: 'period', browse_entries: period_group_of_3.browse_entries + [
        browse_entries(:century_19_period), browse_entries(:century_20_period), browse_entries(:century_21_period)
      ])
    end
    let(:person_group_of_3) do
      BrowseEntryGroup.new(title: 'person', browse_entries: [
        browse_entries(:van_gogh_person), browse_entries(:hokusai_person), browse_entries(:sandro_botticelli_person)
      ])
    end

    context 'when there are no browse entry groups' do
      let(:browse_entry_groups) { [] }
      it { is_expected.to be_valid }
    end
    context 'when there is 1 group of 3 browse entries' do
      let(:browse_entry_groups) { [ topic_group_of_3 ] }
      it { is_expected.to be_valid }
    end
    context 'when there are 2 groups of 3 browse entries' do
      let(:browse_entry_groups) { [ topic_group_of_3, person_group_of_3 ] }
      it { is_expected.to be_valid }
    end
    context 'when there are 3 groups of 3 browse entries' do
      let(:browse_entry_groups) { [ topic_group_of_3, person_group_of_3, period_group_of_3 ] }
      it { is_expected.not_to be_valid }
    end
    context 'when there is 1 group of 6 browse entries' do
      let(:browse_entry_groups) { [ topic_group_of_6 ] }
      it { is_expected.to be_valid }
    end
    context 'when there are 2 groups of 6 browse entries' do
      let(:browse_entry_groups) { [ topic_group_of_6, period_group_of_6 ] }
      it { is_expected.not_to be_valid }
    end
  end

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(PaperTrail::Model::InstanceMethods) }
  end

  describe '#parent' do
    context 'when page has parent' do
      subject { pages(:about_us) }
      it 'should return parent page' do
        expect(subject.parent).to eq(pages(:about))
      end
    end

    context 'when page has no parent' do
      subject { pages(:about) }
      it 'should return nil' do
        expect(subject.parent).to be_nil
      end
    end

    context 'when slug is blank' do
      subject { pages(:home) }
      it 'should return nil' do
        expect(subject.parent).to be_nil
      end
    end
  end

  describe '#children' do
    context 'when page is home' do
      subject { pages(:home) }
      it 'should be blank' do
        expect(subject.children).to be_blank
      end
    end

    context 'when page is not home' do
      subject { pages(:about) }
      it 'should return child pages' do
        expect(subject.children).to include(pages(:about_us))
      end
      it 'should not return grandchild pages' do
        expect(subject.children).not_to include(pages(:about_us_all))
      end
      it 'should not return unrelated pages' do
        expect(subject.children).not_to include(pages(:contact))
      end
    end
  end
end
