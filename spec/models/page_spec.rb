RSpec.describe Page do
  it { is_expected.to belong_to(:banner).inverse_of(:pages) }
  it { is_expected.to belong_to(:hero_image).inverse_of(:page) }
  it { is_expected.to have_many(:browse_entries).through(:elements) }
  it { is_expected.to have_many(:elements).inverse_of(:page) }
  it { is_expected.to validate_uniqueness_of(:slug) }

  it { is_expected.to accept_nested_attributes_for(:hero_image) }

  describe 'browse_entry validation' do
    subject { pages(:about) }
    context 'when there are no browse entries' do
      it 'should be valid' do
       expect(subject).to be_valid
      end
    end
    context 'when there are 3 topic browse entries' do
      before do
        subject.browse_entries.append(browse_entries(:opera_topic))
        subject.browse_entries.append(browse_entries(:cinema_topic))
        subject.browse_entries.append(browse_entries(:music_topic))
      end
      it 'should be valid' do
        expect(subject).to be_valid
      end
    end
    context 'when there are 6 topic browse entries' do
      before do
        subject.browse_entries.append(browse_entries(:opera_topic))
        subject.browse_entries.append(browse_entries(:cinema_topic))
        subject.browse_entries.append(browse_entries(:music_topic))
        subject.browse_entries.append(browse_entries(:harp_topic))
        subject.browse_entries.append(browse_entries(:manuscripts_topic))
        subject.browse_entries.append(browse_entries(:books_topic))
      end
      it 'should be valid' do
        expect(subject).to be_valid
      end
    end
    context 'when there are 3 topic and 3 person browse entries' do
      before do
        subject.browse_entries.append(browse_entries(:opera_topic))
        subject.browse_entries.append(browse_entries(:cinema_topic))
        subject.browse_entries.append(browse_entries(:music_topic))
        subject.browse_entries.append(browse_entries(:van_gogh_person))
        subject.browse_entries.append(browse_entries(:hokusai_person))
        subject.browse_entries.append(browse_entries(:sandro_botticelli_person))
      end
      it 'should be valid' do
        expect(subject).to be_valid
      end
    end
    context 'when there are 3 topic and 3 person browse entries and a facet browse entry' do
      before do
        subject.browse_entries.append(browse_entries(:opera_topic))
        subject.browse_entries.append(browse_entries(:cinema_topic))
        subject.browse_entries.append(browse_entries(:music_topic))
        subject.browse_entries.append(browse_entries(:van_gogh_person))
        subject.browse_entries.append(browse_entries(:hokusai_person))
        subject.browse_entries.append(browse_entries(:sandro_botticelli_person))
        subject.browse_entries.append(browse_entries(:designer_someone_facet))
      end
      it 'should be valid' do
        expect(subject).to be_valid
      end
    end
    context 'when there are 7 topic browse entries' do
      before do
        subject.browse_entries.append(browse_entries(:opera_topic))
        subject.browse_entries.append(browse_entries(:cinema_topic))
        subject.browse_entries.append(browse_entries(:music_topic))
        subject.browse_entries.append(browse_entries(:harp_topic))
        subject.browse_entries.append(browse_entries(:manuscripts_topic))
        subject.browse_entries.append(browse_entries(:books_topic))
        subject.browse_entries.append(browse_entries(:paintings_topic))
      end
      it 'should not be valid' do
        expect(subject).to_not be_valid
      end
    end
    context 'when there are 3 topic and 2 person browse entries' do
      before do
        subject.browse_entries.append(browse_entries(:opera_topic))
        subject.browse_entries.append(browse_entries(:cinema_topic))
        subject.browse_entries.append(browse_entries(:music_topic))
        subject.browse_entries.append(browse_entries(:van_gogh_person))
        subject.browse_entries.append(browse_entries(:hokusai_person))
      end
      it 'should not be valid' do
        expect(subject).to_not be_valid
      end
    end
    context 'when there are 2 topic and 1 person browse entries' do
      before do
        subject.browse_entries.append(browse_entries(:opera_topic))
        subject.browse_entries.append(browse_entries(:cinema_topic))
        subject.browse_entries.append(browse_entries(:van_gogh_person))
      end
      it 'should not be valid' do
        expect(subject).to_not be_valid
      end
    end
    context 'when there are 3 period browse entries' do
      before do
        subject.browse_entries.append(browse_entries(:century_16_period))
        subject.browse_entries.append(browse_entries(:century_17_period))
        subject.browse_entries.append(browse_entries(:century_18_period))
      end
      it 'should be valid' do
        expect(subject).to be_valid
      end
    end
    context 'when there are 2 period browse entries' do
      before do
        subject.browse_entries.append(browse_entries(:century_16_period))
        subject.browse_entries.append(browse_entries(:century_17_period))
      end
      it 'should not be valid' do
        expect(subject).to_not be_valid
      end
    end
    context 'when there are 3 period, 3 topic and 3 person browse entries' do
      before do
        subject.browse_entries.append(browse_entries(:century_16_period))
        subject.browse_entries.append(browse_entries(:century_17_period))
        subject.browse_entries.append(browse_entries(:century_18_period))
        subject.browse_entries.append(browse_entries(:opera_topic))
        subject.browse_entries.append(browse_entries(:cinema_topic))
        subject.browse_entries.append(browse_entries(:music_topic))
        subject.browse_entries.append(browse_entries(:van_gogh_person))
        subject.browse_entries.append(browse_entries(:hokusai_person))
        subject.browse_entries.append(browse_entries(:sandro_botticelli_person))
      end
      it 'should not be valid' do
        expect(subject).to_not be_valid
      end
    end
    context 'when there is 1 topic browse entry' do
      before do
        subject.browse_entries.append(browse_entries(:opera_topic))
      end
      it 'should not be valid' do
        expect(subject).to_not be_valid
      end
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
