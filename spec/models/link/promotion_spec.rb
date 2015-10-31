RSpec.describe Link::Promotion do
  it { is_expected.to be_a(Link) }
  it { is_expected.to belong_to(:media_object) }
  it { is_expected.to delegate_method(:settings_category_enum).to(:class) }
  it { is_expected.to delegate_method(:settings_wide_enum).to(:class) }
  it { is_expected.to delegate_method(:file).to(:media_object) }
  it { is_expected.to validate_inclusion_of(:settings_category).in_array(described_class.settings_category_enum) }
  it { is_expected.to validate_inclusion_of(:settings_wide).in_array(described_class.settings_wide_enum) }

  describe '.settings_category_enum' do
    subject { described_class.settings_category_enum }
    it { is_expected.to eq(%w(collection exhibition new partner featured_site)) }
  end

  describe '.settings_wide_enum' do
    subject { described_class.settings_wide_enum }
    it { is_expected.to eq(['0', '1']) }
  end
end
