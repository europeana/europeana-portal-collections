require 'rails_helper'

RSpec.describe ChannelsHelper, type: :helper do
  describe '#available_channels' do
    before do
      3.times do
        FactoryGirl.create(:channel)
      end
    end
    subject { helper.available_channels }
    it 'should eq channel keys' do
      expect(subject).to eq(Channel.all.map(&:key))
    end
  end
  
  describe '#within_channel?' do
    context 'when search was in a channel' do
      let(:params) { { 'controller' => 'channels', 'id' => 'art' } }
      subject { helper.within_channel?(params) }
      it { is_expected.to eq(true) }
    end

    context 'when search was not in a channel' do
      it 'should eq false' do
        [
          { 'controller' => 'other' },
          { 'controller' => 'channels' },
          { 'controller' => 'other', 'id' => 'art' }
        ].each do |params|
          expect(helper.within_channel?(params)).to eq(false)
        end
      end
    end
  end
end
