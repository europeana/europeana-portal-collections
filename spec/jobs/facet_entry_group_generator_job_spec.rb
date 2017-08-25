# frozen_string_literal: true
RSpec.describe FacetEntryGroupGeneratorJob do
  let(:facet_entry_group) { element_groups(:fashion_designer_facet_group) }

  before do
    subject.instance_variable_set(:@facet_entry_group, facet_entry_group)
    subject.repository # calling reposiotry to populate the instance variable
    allow(subject.instance_variable_get(:@repository)).to receive(:search) { JSON.parse(api_responses(:search_facet_creator)) }
  end

  it 'retrieves x number of facet values for the facet_field and creates facet_entries for them' do
    subject.perform(facet_entry_group.id)
    facet_entries = facet_entry_group.facet_entries
    expect(facet_entries.count).to eq(6)
    expect(facet_entries.first.facet_field).to eq('CREATOR')
    expect(facet_entries.first.facet_value).to eq('Emilio Pucci (Designer)')
    expect(facet_entries.first.query).to eq('q=&f[CREATOR][]=Emilio Pucci (Designer)&f[THUMBNAIL][]=true')

    expect(facet_entry_group.page_landing.facet_entries).to eq facet_entries
  end
end
