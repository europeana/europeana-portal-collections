RSpec.describe Channel do
  it { should validate_presence_of(:key) }
  it { should validate_uniqueness_of(:key) }
  it { should validate_presence_of(:api_params) }

  describe '#title' do
    let(:channel_title) { 'All about fishing' }
    it 'should be looked up in I18n locale' do
      I18n.locale = :en
      I18n.backend.store_translations(:en, site: { channels: { fishing: { title: channel_title } } })
      channel = FactoryGirl.create(:channel, key: 'fishing')
      expect(channel.title).to eq(channel_title)
    end
  end

  describe '#to_param' do
    context 'when key eq "literature"' do
      let(:channel) { FactoryGirl.create(:channel, key: 'literature') }
      subject { channel.to_param }
      it { is_expected.to eq(channel.key) }
    end
  end
end
