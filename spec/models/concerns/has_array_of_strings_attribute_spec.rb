# frozen_string_literal: true

RSpec.describe HasArrayOfStringsAttribute do
  let(:model_class) do
    Class.new do
      include HasArrayOfStringsAttribute
      attr_accessor :tags
      has_array_of_strings_attribute :tags, join: ', ', split: ','
    end
  end

  subject { model_class.new }

  it { is_expected.to have_array_of_strings_attribute(:tags).joining(', ').splitting(',') }
end
