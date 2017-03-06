# frozen_string_literal: true
RSpec.describe Pro::BlogPost do
  it { is_expected.to be_a(Pro::Base) }

  describe '.table_name' do
    it 'should be "blogposts"' do
      expect(described_class.table_name).to eq('blogposts')
    end
  end
end
