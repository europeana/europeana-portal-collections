require 'rails_helper'

RSpec.describe SearchHistoryConstraintsHelper, type: :helper do
  it { is_expected.to include(Blacklight::SearchHistoryConstraintsHelperBehavior) }

  describe '#render_search_to_s' do
    context 'when search was in a channel' do
      let(:params) { { 'controller' => 'channels', 'id' => 'art' } }
      subject { helper.render_search_to_s(params) }
      it { is_expected.to include('Channel') }
      it { is_expected.to include('art') }
    end

    context 'when search was not in a channel' do
      it 'should not include channel search summary' do
        [
          { 'controller' => 'other' },
          { 'controller' => 'channels' },
          { 'controller' => 'other', 'id' => 'art' }
        ].each do |params|
          expect(helper.render_search_to_s(params)).not_to include('Channel')
        end
      end
    end
  end

  describe '#render_search_to_s_channel' do
    context 'when search was in a channel' do
      let(:params) { { 'controller' => 'channels', 'id' => 'art' } }
      subject { helper.render_search_to_s_channel(params) }
      it { is_expected.to include('Channel') }
      it { is_expected.to include('art') }
    end

    context 'when search was not in a channel' do
      it 'should not include channel search summary' do
        [
          { 'controller' => 'other' },
          { 'controller' => 'channels' },
          { 'controller' => 'other', 'id' => 'art' }
        ].each do |params|
          expect(helper.render_search_to_s_channel(params)).to eq('')
        end
      end
    end
  end
end
