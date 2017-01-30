# frozen_string_literal: true
RSpec.describe GalleryImage do
  it { is_expected.to belong_to(:gallery).inverse_of(:images) }
  it { is_expected.to validate_presence_of(:gallery) }
  it { is_expected.to validate_presence_of(:europeana_record_id) }
  it { is_expected.to allow_values('/abc/123', '/123/abc').for(:europeana_record_id) }
  it { is_expected.not_to allow_values('abc/123', 'record/123/abc', 'http://www.europeana.eu/').for(:europeana_record_id) }

#   describe '#portal_url=' do
#     %w(
#       http://www.europeana.eu/portal/record/abc/123.html
#       http://www.europeana.eu/portal/record/abc/123
#       https://www.europeana.eu/portal/record/abc/123.html
#       https://www.europeana.eu/portal/record/abc/123
#       http://www.europeana.eu/portal/en/record/abc/123.html
#       https://www.europeana.eu/portal/de/record/abc/123
#     ).each do |url|
#       context %(with valid portal URL "#{url}") do
#         it 'should assign record ID' do
#           image = described_class.new(gallery: galleries(:empty), portal_url: url)
#           expect(image).to be_valid
#           expect(image.europeana_record_id).to eq('/abc/123')
#         end
#       end
#     end

#     %w(
#       ftp://www.europeana.eu/portal/record/abc/123.html
#       http://www.europeana.eu/portal
#       https://www.europeana.eu/portal/record/abc/123/parent.html
#       https://www.europeana.eu/portal/record/abc/123.json
#       http://www.example.com/portal/record/abc/123.html
#     ).each do |url|
#       context %(with invalid portal URL "#{url}") do
#         it 'should not assign record ID' do
#           image = described_class.new(gallery: galleries(:empty), portal_url: url)
#           expect(image).not_to be_valid
#           expect(image.errors[:portal_url]).not_to be_none
#           expect(image.europeana_record_id).to be_nil
#         end
#       end
#     end
#   end
end
