module Browse
  class NewContent < ApplicationView
    def page_title
      mustache[:page_title] ||= begin
        [t('site.browse.newcontent.title'), site_title].join(' - ')
      end
    end

    def content
      mustache[:content] ||= begin
        {
          title: page_title,
          description: t('site.browse.newcontent.description'),
          recent: @providers.blank? ? nil : {
            title: ' ',
            items: stylised_recent_additions(@providers, max: 1000, from: :same),
            tableh1: t('site.browse.newcontent.tableh1'),
            tableh2: t('site.browse.newcontent.tableh2'),
            tableh3: t('site.browse.newcontent.tableh3')
          }
        }
      end
    end

    def head_meta
      mustache[:head_meta] ||= begin
        [
          { meta_name: 'description', content: page_title }
        ] + super
      end
    end

    private

    def body_cache_key
      'browse/newcontent'
    end
  end
end
