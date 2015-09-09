RSpec.describe UrlValidator do
  class TestLink
    include ActiveModel::Model
    attr_accessor :url
    validates :url, url: true, allow_nil: true
    attr_accessor :local_url
    validates :local_url, url: { allow_local: true }, allow_nil: true
  end

  it 'sub-classes ActiveModel::EachValidator' do
    expect(described_class.superclass).to eq(ActiveModel::EachValidator)
  end

  describe '#validate_each' do
    ['http://www.example.com', 'http://www.example.com/',
     'http://www.example.com/sub/path.html', 'https://example.com/fish.png',
     'https://www.example.com/search?q=cookery'].each do |url|
      context "when value is \"#{url}\"" do
        subject { TestLink.new(url: url) }
        it { is_expected.to be_valid }
      end
    end

    ['ftp://www.example.com', '://www.example.com/', '/', '/sub/path/to.png',
     'www.example.com/sub/path.html', 'fish.png', 'cookery', ''].each do |url|
      context "when value is \"#{url}\"" do
        subject { TestLink.new(url: url) }
        it { is_expected.not_to be_valid }
      end
    end

    context 'when options[:allow_local] is true' do
      ['/', '/sub/path/to.png'].each do |url|
        context "when value is \"#{url}\"" do
          subject { TestLink.new(local_url: url) }
          it { is_expected.to be_valid }
        end
      end
    end
  end
end
