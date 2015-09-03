RSpec.describe BrowseEntry do
  it { is_expected.to belong_to(:landing_page) }
  it { is_expected.to belong_to(:media_object) }
  it { is_expected.to delegate_method(:settings_category_enum).to(:class) }
  it { is_expected.to delegate_method(:file).to(:media_object) }
  it { is_expected.to accept_nested_attributes_for(:media_object) }
  it { is_expected.to validate_inclusion_of(:settings_category).in_array(described_class.settings_category_enum) }

  describe '.settings_category_enum' do
    subject { described_class.settings_category_enum }
    it { is_expected.to eq(%w(search spotlight)) }
  end
end
