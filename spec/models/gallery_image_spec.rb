# frozen_string_literal: true
RSpec.describe GalleryImage do
  it { is_expected.to belong_to(:gallery).inverse_of(:images) }
  it { is_expected.to validate_presence_of(:gallery) }
  it { is_expected.to validate_presence_of(:record_url) }

  it 'should validate record_url is a Europeana portal record URL'
  it 'should remove language code from record_url'
  it 'should remove query params from record_url'
  it 'should enforce http:// schema on record_url'
  it 'should validate uniqueness of record url within gallery scope'
  it 'should queue a job to retrieve record metadata'
end
