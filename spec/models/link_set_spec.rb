RSpec.describe LinkSet do
  it { is_expected.to have_many(:links) }
  it { is_expected.to accept_nested_attributes_for(:links) }
end
