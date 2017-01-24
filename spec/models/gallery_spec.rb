# frozen_string_literal: true
RSpec.describe Gallery do
  it { is_expected.to have_many(:images).inverse_of(:gallery).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:title) }
  it { should validate_length_of(:title).is_at_most(60) }
  it { should validate_length_of(:description).is_at_most(280) }
  it { is_expected.to be_versioned }
  it { should accept_nested_attributes_for(:images).allow_destroy(true) }
  it { should accept_nested_attributes_for(:translations).allow_destroy(true) }

  it 'should have publication states' do
    expect(described_class).to include(HasPublicationStates)
  end

  it 'should translate title' do
    expect(described_class.translated_attribute_names).to include(:title)
  end

  it 'should translate description' do
    expect(described_class.translated_attribute_names).to include(:description)
  end
end
