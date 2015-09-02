describe Europeana::Portal::Application, 'configuration' do
  let(:config) { described_class.config }

  it 'has channels config' do
    expect(config.x.channels).not_to be_blank
  end
end
