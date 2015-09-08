module Portal
  class Static < ApplicationView
    def page_title
      content[:title]
    end

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
      }.merge(helpers.content)
    end

    def content_channels_music_about
      {
        title: t('site.pages.music-channel-about.title'),
        text: t('site.pages.music-channel-about.text')
      }.merge(helpers.content)
    end
  end
end
