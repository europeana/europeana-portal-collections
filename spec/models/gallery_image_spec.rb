# frozen_string_literal: true
RSpec.describe GalleryImage do
  it { is_expected.to belong_to(:gallery).inverse_of(:images) }
  it { is_expected.to validate_presence_of(:gallery) }
  it { is_expected.to validate_presence_of(:record_url) }
  it { is_expected.to validate_uniqueness_of(:position).scoped_to(:gallery_id) }
end
