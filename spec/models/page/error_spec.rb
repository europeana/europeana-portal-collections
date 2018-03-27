# frozen_string_literal: true

RSpec.describe Page::Error do
  it { is_expected.to validate_presence_of(:http_code) }
  it { is_expected.to validate_uniqueness_of(:http_code) }
end
