# frozen_string_literal: true
RSpec.describe Categorisation do
  it { is_expected.to validate_presence_of(:topic_id) }
  it { is_expected.to validate_presence_of(:categorisable) }
  it { is_expected.to belong_to(:topic).inverse_of(:categorisations) }
  it { is_expected.to belong_to(:categorisable) }
end
