module Browse
  class NewContent < ApplicationView
    def page_title
      mustache[:page_title] ||= begin
        t('site.browse.newcontent.title')
      end
    end

    def content
      mustache[:content] ||= begin
        {
          title: page_title,
          recent: @providers.blank? ? nil : {
            title: t('site.collections.labels.recent'),
            items: stylised_recent_additions(@providers, max: 1000, from: :same)
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
  end
end
