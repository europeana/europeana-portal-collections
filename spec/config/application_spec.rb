describe Europeana::Portal::Application, 'configuration' do
  let(:config) { described_class.config }

  it 'has channels config' do
    expect(config.channels).not_to be_blank
  end

  it 'has fog config' do
    expect(config.fog).not_to be_blank
  end

  it 'sets paperclip defaults' do
    expect(config.paperclip_defaults[:storage]).to eq(:fog)
  end
end
