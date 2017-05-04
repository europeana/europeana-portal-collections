RSpec.describe Link::SocialMedia do
  it { is_expected.to be_a(Link) }

  describe '#facebook?' do
    context 'when URL is for facebook.com' do
      subject { described_class.new(url: 'https://www.facebook.com/Europeana').facebook? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal').facebook? }
      it { is_expected.to be false }
    end
  end

  describe '#googleplus?' do
    context 'when URL is for plus.google.com' do
      subject { described_class.new(url: 'https://plus.google.com/+europeana').googleplus? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal').googleplus? }
      it { is_expected.to be false }
    end
  end

  describe '#instagram?' do
    context 'when URL is for instagram.com' do
      subject { described_class.new(url: 'https://instagram.com/europeanaeu').instagram? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal').instagram? }
      it { is_expected.to be false }
    end
  end

  describe '#linkedin?' do
    context 'when URL is for linkedin.com' do
      subject { described_class.new(url: 'https://www.linkedin.com/company/europeana').linkedin? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal').linkedin? }
      it { is_expected.to be false }
    end
  end

  describe '#pinterest?' do
    context 'when URL is for pinterest.com' do
      subject { described_class.new(url: 'https://www.pinterest.com/europeana/').pinterest? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal').pinterest? }
      it { is_expected.to be false }
    end
  end

  describe '#soundcloud?' do
    context 'when URL is for soundcloud.com' do
      subject { described_class.new(url: 'https://soundcloud.com/europeana').soundcloud? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal').soundcloud? }
      it { is_expected.to be false }
    end
  end

  describe '#tumblr?' do
    context 'when URL is for tumblr.com' do
      subject { described_class.new(url: 'http://europeanacollections.tumblr.com/').tumblr? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal').tumblr? }
      it { is_expected.to be false }
    end
  end

  describe '#twitter?' do
    context 'when URL is for twitter.com' do
      subject { described_class.new(url: 'https://twitter.com/europeanaeu').twitter? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal').twitter? }
      it { is_expected.to be false }
    end
  end

  describe '#europeana_blog?' do
    context 'when URL is for blog.europeana.eu' do
      subject { described_class.new(url: 'https://blog.europeana.eu/something').europeana_blog? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal').europeana_blog? }
      it { is_expected.to be false }
    end
  end

  describe '#pro_blog?' do
    context 'when URL is for europeana.eu/portal/.../blogs.rss' do
      subject { described_class.new(url: 'https://europeana.eu/portal/en/blogs.rss?theme=fahsion').pro_blog? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu/.../events' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal/en/events').pro_blog? }
      it { is_expected.to be false }
    end
  end

  describe '#pro_events?' do
    context 'when URL is for europeana.eu/portal/.../events.rss' do
      subject { described_class.new(url: 'https://europeana.eu/portal/en/events.rss?theme=fahsion').pro_events? }
      it { is_expected.to be true }
    end

    context 'when URL is for europeana.eu/.../blogs' do
      subject { described_class.new(url: 'https://www.europeana.eu/portal/en/blogs').pro_events? }
      it { is_expected.to be false }
    end
  end

  describe '#url_in_domain?' do
    context 'when URL is "http://www.europeana.eu/"' do
      let(:url) { 'http://www.europeana.eu/' }

      context 'domain is europeana.eu' do
        subject { described_class.new(url: url).url_in_domain?('europeana.eu') }
        it { is_expected.to be true }
      end

      context 'domain is europeana.com' do
        subject { described_class.new(url: url).url_in_domain?('europeana.com') }
        it { is_expected.to be false }
      end
    end
  end
end
