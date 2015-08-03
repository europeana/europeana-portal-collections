module Templates
  module Search
    class SearchStaticPage < ApplicationView
      def content
        case @page
        when 'about'
          content_about
        when 'channels/music/about'
          content_channels_music_about
        end
      end

      private

      def content_about
        {
          title: t('site.pages.about.title'),
          text: t('site.pages.about.text')
        }
      end

      def content_channels_music_about
        {
          title: t('site.pages.music-channel-about.title'),
          text: t('site.pages.music-channel-about.text')
        }
      end
    end
  end
end
