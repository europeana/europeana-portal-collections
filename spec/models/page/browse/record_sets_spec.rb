# frozen_string_literal: true

RSpec.describe Page::Browse::RecordSets do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to have_many(:sets).through(:elements) }
  it { is_expected.to accept_nested_attributes_for(:sets) }

  describe '#europeana_ids' do
    it 'gathers unique IDs of all sets' do
      subject.sets.push(Europeana::Record::Set.new(europeana_ids: %w(/123/abc /456/def)))
      subject.sets.push(Europeana::Record::Set.new(europeana_ids: %w(/456/def /789/ghi)))
      expect(subject.europeana_ids).to eq(%w(/123/abc /456/def /789/ghi))
    end
  end
end
