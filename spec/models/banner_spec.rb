RSpec.describe Banner do
  it { is_expected.to have_one(:link) }
  it { is_expected.to validate_uniqueness_of(:key).allow_nil }
  it { is_expected.to accept_nested_attributes_for(:link) }
  it { is_expected.to delegate_method(:url).to(:link).with_prefix(true) }
  it { is_expected.to delegate_method(:text).to(:link).with_prefix(true) }
end
