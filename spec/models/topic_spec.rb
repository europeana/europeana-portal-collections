# frozen_string_literal: true
RSpec.describe Topic do
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_uniqueness_of(:label) }
  it { is_expected.to validate_uniqueness_of(:entity_uri).allow_blank }
  it { is_expected.to have_many(:categorisations).inverse_of(:topic).dependent(:destroy) }

  it 'should translate label' do
    expect(described_class.translated_attribute_labels).to include(:label)
  end

  it 'should set the slug from the label' do
    topic = Topic.create(label: 'Art history')
    expect(topic.slug).to eq('art-history')
  end

  describe '#to_param' do
    it 'should return the slug' do
      topic = Topic.new(label: 'Art history', slug: 'art-history')
      expect(topic.to_param).to eq('art-history')
    end
  end
end
