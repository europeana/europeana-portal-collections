# frozen_string_literal: true

RSpec.describe PageElement do
  it { is_expected.to belong_to(:group).inverse_of(:elements).touch(true) }
  it { is_expected.to have_one(:page).through(:group).inverse_of(:elements) }
  it { is_expected.to belong_to(:positionable) }
end
