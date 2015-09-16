RSpec.describe Page do
  it { is_expected.to belong_to(:hero_image) }
  it { is_expected.to validate_uniqueness_of(:slug).allow_blank }

  it { is_expected.to accept_nested_attributes_for(:hero_image) }

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(PaperTrail::Model::InstanceMethods) }
  end
end
