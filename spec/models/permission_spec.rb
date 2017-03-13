# frozen_string_literal: true
RSpec.describe Permission do
  it { is_expected.to belong_to(:permissionable) }
  it { is_expected.to belong_to(:user).inverse_of(:permissions) }
end
