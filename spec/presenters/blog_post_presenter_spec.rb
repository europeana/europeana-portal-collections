# frozen_string_literal: true
RSpec.describe BlogPostPresenter do
  subject { described_class.new(blog_post) }

  let(:blog_post) { double(Pro::BlogPost) }
  let(:last_result_set) { double(JsonApiClient::ResultSet) }
  let(:included_data) { double(JsonApiClient::IncludedData) }

  before do
    allow(last_result_set).to receive(:included) { included_data }
    allow(blog_post).to receive(:last_result_set) { last_result_set }
    allow(included_data).to receive(:has_link?) { false }
  end

  context 'without taxonomy' do
    it { is_expected.not_to have_taxonomy }
    it { is_expected.not_to have_tags }
    it { is_expected.not_to have_label }
  end

  context 'with taxonomy' do
    before do
      allow(blog_post).to receive(:taxonomy) { { a: [] } }
    end
    it { is_expected.to have_taxonomy }
    it { is_expected.not_to have_tags }
    it { is_expected.not_to have_label }

    context 'with tags' do
      before do
        allow(blog_post).to receive(:taxonomy) { { tags: ['a'] } }
      end
      it { is_expected.to have_tags }
    end

    context 'with blogs' do
      before do
        allow(blog_post).to receive(:taxonomy) { { blogs: { '/path' => 'interesting blog' } } }
      end
      it { is_expected.to have_label }
    end
  end

  context 'with persons' do
    before do
      allow(blog_post).to receive(:persons) { [double(Pro::Person)] }
      allow(included_data).to receive(:has_link?).with(:persons) { true }
    end
    it { is_expected.to have_included(:persons) }
    it { is_expected.to have_authors }
  end

  context 'with network' do
    before do
      allow(blog_post).to receive(:network) { [double(Pro::Network)] }
      allow(included_data).to receive(:has_link?).with(:network) { true }
    end
    it { is_expected.to have_included(:network) }
    it { is_expected.to have_authors }
  end

  context 'without persons or network' do
    it { is_expected.not_to have_authors }
  end

  describe '#date' do
    it 'formats datepublish' do
      allow(blog_post).to receive(:datepublish) { '2017-02-15T14:12:00+00:00' }
      expect(subject.date).to eq('15 February, 2017')
    end
  end

  describe '#label' do
    it 'uses the first value of blogs taxonomy' do
      allow(blog_post).to receive(:taxonomy) { { blogs: { '/path' => 'interesting blog' } } }
      expect(subject.label).to eq('interesting blog')
    end
  end

  describe '#pro_url' do
    it 'returns a full URL to Pro resource' do
      allow(Pro).to receive(:site) { 'http://www.example.com' }
      expect(subject.pro_url('/path')).to eq('http://www.example.com/path')
    end
  end

  describe '#body' do
    it 'replaces relative paths' do
      allow(Pro).to receive(:site) { 'http://www.example.com' }
      allow(blog_post).to receive(:body) { '<a href="/path"></a><img src="/path" />' }
      absolute = '<a href="http://www.example.com/path"></a><img src="http://www.example.com/path" />'
      expect(subject.body).to eq(absolute)
    end
  end

  describe '#excerpt' do
    let(:body) { '<p>' + ('word ' * 80).strip + '</p>' }
    before do
      allow(blog_post).to receive(:body) { body }
    end
    it 'truncates body to 350 chars' do
      expect(subject.excerpt.length).to be <= 350
    end
    it 'strips tags' do
      expect(subject.excerpt).not_to include('<p>')
    end
    it 'ends with ellipsis on word boundary' do
      expect(subject.excerpt).to end_with('word...')
    end
  end
end
