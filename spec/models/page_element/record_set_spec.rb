# frozen_string_literal: true
RSpec.describe PageElement::RecordSet do
  it { is_expected.to belong_to(:page).class_name('Page::Browse::RecordSets').inverse_of(:sets) }
  it { is_expected.to validate_presence_of(:page) }
  it { is_expected.to validate_presence_of(:europeana_ids) }
  it { is_expected.to validate_presence_of(:title) }
end
