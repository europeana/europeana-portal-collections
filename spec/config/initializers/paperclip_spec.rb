RSpec.describe Paperclip::Attachment do
  it 'sets paperclip defaults' do
    expect(described_class.default_options[:styles]).to have_key(:small)
  end
end
