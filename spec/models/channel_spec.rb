require 'rails_helper'

RSpec.describe Channel, type: :model do
  before do
    app = class_double('Europeana::Portal::Application').as_stubbed_const
    app_config = double('app config')
    channels_config = { 'art' => { query: 'pictures' }, 'music' => { query: 'sounds' } }
    allow(app_config).to receive(:channels).and_return(channels_config)
    allow(app).to receive(:config).and_return(app_config)
  end

  describe '.find' do
    it 'validates requested channel' do
      expect { Channel.find('unknown') }.to raise_error(Channels::Errors::NoChannelConfiguration)
    end

    it 'looks to app config for a channel' do
      expect(Europeana::Portal::Application).to receive(:config)
      channel = Channel.find('art')
      expect(channel).to be_a(Channel)
      expect(channel.config).to eq({ query: 'pictures' })
    end
  end

  describe '#initialize' do
    it 'requires Symbol arg' do
      expect { Channel.new(:art) }.to raise_error(/Channel ID must be a String/)
      expect { Channel.new('art') }.not_to raise_error
    end
  end

  describe '#method_missing' do
    it 'looks up data in config' do
      channel = Channel.new('history')
      channel.config = { query: 'old' }
      expect { channel.query }.not_to raise_error
      expect(channel.query).to eq('old')
    end
  end
end
