RSpec.shared_context 'Blacklight config', :blacklight_config do
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = 'title_display'
    end
  end

end
