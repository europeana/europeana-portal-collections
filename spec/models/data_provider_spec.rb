RSpec.describe DataProvider do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:uri) }
  it { is_expected.to validate_uniqueness_of(:uri) }
end
