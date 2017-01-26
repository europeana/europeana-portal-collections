# frozen_string_literal: true
RSpec.describe GalleryImage do
  it { is_expected.to belong_to(:gallery).inverse_of(:images) }
  it { is_expected.to belong_to(:europeana_record).inverse_of(:gallery_images) }
  it { is_expected.to validate_presence_of(:gallery) }
  it { is_expected.to validate_presence_of(:europeana_record) }
  it { is_expected.to delegate_method(:metadata).to(:europeana_record) }
  it { is_expected.to delegate_method(:url).to(:europeana_record) }

  describe '#url=' do
    context 'when Europeana::Record exists for url' do
      it 'should associate image with Europeana record' do
        record = Europeana::Record.create!(europeana_id: '/this/that')
        image = described_class.new(url: 'http://www.europeana.eu/portal/record/this/that.html')
        expect(image.europeana_record).to eq(record)
      end
    end

    context 'when no Europeana::Record exists for url' do
      it 'should build a new Europeana record for image' do
        image = described_class.new(gallery: galleries(:empty), url: 'http://www.europeana.eu/portal/record/the/other.html')
        expect(image.europeana_record).to be_a(Europeana::Record)
        expect(image.europeana_record).to be_new_record
        expect(image.europeana_record.europeana_id).to eq('/the/other')
        image.save
        expect(image.europeana_record.reload).not_to be_new_record
      end
    end
  end
end
