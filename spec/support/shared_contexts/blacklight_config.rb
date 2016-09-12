RSpec.shared_context 'Blacklight config', :blacklight_config do
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = 'title_display'
      config.add_facet_field 'COLLECTION', include_in_request: false, single: true
      config.add_facet_field 'TYPE', hierarchical: true
    end
  end

  before(:each) do
    allow(controller).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
  end
end
