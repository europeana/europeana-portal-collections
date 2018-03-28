# frozen_string_literal: true

RSpec.describe DataProviderLogo do
  it { should belong_to(:data_provider) }
end
