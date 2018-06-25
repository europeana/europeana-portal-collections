# frozen_string_literal: true

RSpec.describe Page::Browse::RecordSets do
  it { is_expected.to have_many(:sets).class_name('PageElement::RecordSet').inverse_of(:page).dependent(:destroy) }
end
