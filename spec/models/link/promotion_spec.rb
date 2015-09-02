RSpec.describe Link::Promotion do
  it { is_expected.to be_a(Link) }
  it { is_expected.to belong_to(:media_object) }
  it { is_expected.to delegate_method(:settings_category_enum).to(:class) }
  it { is_expected.to delegate_method(:settings_wide_enum).to(:class) }
  it { is_expected.to delegate_method(:file).to(:media_object) }
  it { is_expected.to validate_inclusion_of(:settings_category).in_array(%w(channel exhibition new partner featured_site)) }
  it { is_expected.to validate_inclusion_of(:settings_wide).in_array([true, false]) }

  describe '.settings_category_enum' do
    subject { described_class.settings_category_enum }
    it { is_expected.to eq(%w(channel exhibition new partner featured_site)) }
  end

  describe '.settings_wide_enum' do
    subject { described_class.settings_wide_enum }
    it { is_expected.to eq([true, false]) }
  end

  context 'new record' do
    subject { FactoryGirl.build(:promotion_link) }
    it 'has a media object built' do
      expect(subject.media_object).not_to be_nil
    end
  end
end
