# frozen_string_literal: true

RSpec.describe Link do
  it { is_expected.to belong_to(:linkable) }
  it { is_expected.to validate_presence_of(:url) }

  it 'should validate :url as URL'

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(PaperTrail::Model::InstanceMethods) }
  end
end
