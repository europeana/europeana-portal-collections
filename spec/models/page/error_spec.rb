RSpec.describe Page::Error do
  it { is_expected.to validate_presence_of(:http_code) }
  it { is_expected.to validate_uniqueness_of(:http_code) }
  it { is_expected.to validate_inclusion_of(:http_code).in_array(Rack::Utils::HTTP_STATUS_CODES.keys.select { |code| (400..599).include?(code) }) }
end
