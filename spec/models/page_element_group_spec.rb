# frozen_string_literal: true

RSpec.describe PageElementGroup do
  it { is_expected.to belong_to(:page).inverse_of(:element_groups).touch(true) }
  it { is_expected.to have_many(:elements).inverse_of(:group).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:page_id) }
  it { is_expected.to be_translated(:title) }
end
