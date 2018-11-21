# frozen_string_literal: true

RSpec.describe NewsHelper do
  describe '#news_promo_content' do
    subject { helper.news_promo_content(post) }

    context 'when post is nil' do
      let(:post) { nil }
      it { is_expected.to be_nil }
    end


    context 'when post is from Pro' do
      let(:post) { Pro::Post.new(params) }
      let(:params) do
        {
          'attributes' => {
            'slug' => 'news-post',
            'datepublish' => '2018-08-14T00:00:00+02:00',
            'title' => 'Title',
            'teaser' => 'Post teaser',
            'image' => {
              'thumbnail' => 'https://www.example.org/image.jpeg'
            },
            'image_attribution_holder' => 'Institution'
          }
        }
      end

      it 'returns promo card content' do
        promo_card = {
          url: post.url,
          title: 'Title',
          date: '2018-08-14',
          attribution: 'Institution',
          description: 'Post teaser',
          type: 'News',
          images: %w(https://www.example.org/image.jpeg)
        }
        expect(subject).to eq(promo_card)
      end
    end
  end
end
