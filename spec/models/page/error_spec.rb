RSpec.describe Page::Error do
  it { is_expected.to validate_presence_of(:http_code) }
  it { is_expected.to validate_uniqueness_of(:http_code) }
#  it { is_expected.to validate_inclusion_of(:http_code).in_array(described_class::HTTP_ERROR_STATUS_CODES) }
end
