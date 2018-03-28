# frozen_string_literal: true

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
    expected_keys = %w(app apps blog blogs collection collections dataset datasets event events exhibition exhibitions
                       featured_site featured_sites new partner partners story stories timeline timelines playlist
                       playlists gallery galleries)
    it { is_expected.to eq(expected_keys) }
  end

  describe '.settings_wide_enum' do
    subject { described_class.settings_wide_enum }
    it { is_expected.to eq(%w(0 1)) }
  end
end
