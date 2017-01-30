# frozen_string_literal: true
RSpec.describe GalleryImage do
  it { is_expected.to belong_to(:gallery).inverse_of(:images) }
  it { is_expected.to validate_presence_of(:gallery) }
  it { is_expected.to validate_presence_of(:europeana_record_id) }
  it { is_expected.to allow_values('/abc/123', '/123/abc').for(:europeana_record_id) }
  it { is_expected.not_to allow_values('abc/123', 'record/123/abc', 'http://www.europeana.eu/').for(:europeana_record_id) }
end
