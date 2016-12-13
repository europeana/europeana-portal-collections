RSpec.describe Page::Landing do
  it { is_expected.to belong_to(:hero_image) }
  it { is_expected.to have_many(:credits) }
  it { is_expected.to have_many(:social_media) }
  it { is_expected.to have_many(:promotions) }

  it { is_expected.to accept_nested_attributes_for(:hero_image) }
  it { is_expected.to accept_nested_attributes_for(:credits) }
  it { is_expected.to accept_nested_attributes_for(:social_media) }
  it { is_expected.to accept_nested_attributes_for(:promotions) }
  it { is_expected.to accept_nested_attributes_for(:browse_entries) }

  it { is_expected.to delegate_method(:file).to(:hero_image).with_prefix(true) }

  it { is_expected.to validate_inclusion_of(:layout_type).in_array(%w(default browse))}

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(PaperTrail::Model::InstanceMethods) }
  end
end
