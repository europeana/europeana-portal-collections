require 'rails_helper'

RSpec.describe FacetsHelper, type: :helper do
  it { is_expected.to include(Blacklight::FacetsHelperBehavior) }

  describe '#facet_in_params?' do
    let(:channel_id) { 'art' }
    
    subject { helper.facet_in_params?(field, channel_id) }
    
    before(:each) do
      allow(helper).to receive(:params).and_return(params)
      allow(helper).to receive(:within_channel?).and_return(within_channel)
      allow(helper).to receive(:facet_value_for_facet_item).and_return(channel_id)
      helper.class.send(:include, Blacklight::Configurable)
    end

    context 'when field is "CHANNEL"' do
      let(:field) { 'CHANNEL' }

      context 'and viewing queried channel' do
        let(:params) { { id: channel_id } }
        let(:within_channel) { true }
        it { is_expected.to eq(true) }
      end

      context 'and viewing another channel' do
        let(:params) { { id: 'music' } }
        let(:within_channel) { true }
        it { is_expected.to eq(false) }
      end

      context 'and not viewing a channel' do
        let(:params) { { } }
        let(:within_channel) { false }
        it { is_expected.to eq(false) }
      end
    end

    context 'when field is not "CHANNEL"' do
      let(:field) { 'YEAR' }

      context 'and viewing queried channel' do
        let(:params) { { id: channel_id } }
        let(:within_channel) { true }
        it { is_expected.to eq(false) }
      end

      context 'and viewing another channel' do
        let(:params) { { id: 'music' } }
        let(:within_channel) { true }
        it { is_expected.to eq(false) }
      end

      context 'and not viewing a channel' do
        let(:params) { { } }
        let(:within_channel) { false }
        it { is_expected.to eq(false) }
      end
    end
  end

  describe '#create_facet_field_response_for_query_facet_field' do
    it 'does stuff...'
  end
end
