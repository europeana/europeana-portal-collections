RSpec.describe PageElement do
  it { is_expected.to belong_to(:page).inverse_of(:elements) }
  it { is_expected.to belong_to(:positionable) }
end
