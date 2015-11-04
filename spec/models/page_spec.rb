RSpec.describe Page do
  it { is_expected.to belong_to(:hero_image) }
  it { is_expected.to validate_uniqueness_of(:slug) }

  it { is_expected.to accept_nested_attributes_for(:hero_image) }

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
