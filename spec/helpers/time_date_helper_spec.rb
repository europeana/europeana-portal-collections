RSpec.describe TimeDateHelper do
  describe '#unix_time_to_local' do
    it 'converts Unix time in ms to local' do
      unix_time = 1451606400000 # 1 Jan 2016 00:00:00
      local_time = helper.unix_time_to_local(unix_time)
      expect(local_time).to be_a(DateTime)
      expect(local_time.to_s).to eq('2016-01-01T01:00:00+00:00')
    end
  end
end
