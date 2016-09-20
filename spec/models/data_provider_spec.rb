# frozen_string_literal: true
RSpec.describe DataProvider do
  it { should have_one(:logo) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:uri) }
  it { is_expected.to validate_uniqueness_of(:uri) }
  it { should allow_value('http://data.europeana.eu/organization/000006').for(:uri) }
  it { should_not allow_value('http://data.europeana.eu/organization/0006').for(:uri) }
  it { should_not allow_value('http://europeana.eu/organization/000006').for(:uri) }
  it { should_not allow_value('http://data.example.com/organization/000006').for(:uri) }
  it { should delegate_method(:image).to(:logo) }
end
