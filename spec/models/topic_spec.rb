# frozen_string_literal: true
RSpec.describe Topic do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_uniqueness_of(:entity_uri).allow_blank }
  it { is_expected.to have_many(:categorisations).inverse_of(:topic).dependent(:destroy) }

  it 'should translate name' do
    expect(described_class.translated_attribute_names).to include(:name)
  end

  it 'should set the slug from the name' do
    topic = Topic.create(name: 'Art history')
    expect(topic.slug).to eq('art-history')
  end

  describe '#to_param' do
    it 'should return the slug' do
      topic = Topic.new(name: 'Art history', slug: 'art-history')
      expect(topic.to_param).to eq('art-history')
    end
  end
end
