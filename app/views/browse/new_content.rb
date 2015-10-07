module Browse
  class NewContent < ApplicationView
    def page_title
      t('site.browse.newcontent.title')
    end

    def content
      {
        title: page_title,
        recent: @providers.blank? ? nil : {
          title: t('site.channels.labels.recent'),
          items: stylised_recent_additions(@providers, max: 1000, from: :same)
        }
      }
    end

    def head_meta
      [
        { meta_name: 'description', content: page_title }
      ] + super
    end
  end
end
