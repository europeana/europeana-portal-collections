# frozen_string_literal: true

RSpec.describe Page::Browse::RecordSets do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to have_many(:sets).through(:elements) }
  it { is_expected.to accept_nested_attributes_for(:sets) }
end
