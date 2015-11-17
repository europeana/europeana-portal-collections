module Browse
  class Sources < ApplicationView
    def page_title
      mustache[:page_title] ||= begin
        t('site.browse.sources.title')
      end
    end

    def content
      mustache[:content] ||= begin
        {
          title: page_title,
          providers: @providers.blank? ? nil : {
            title: page_title,
            #items: stylised_providers
            data: stylised_providers,
            inline: true
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

    protected

    def stylised_providers
      @providers.each do |provider|
        provider[:count] = number_with_delimiter(provider[:count])
        dps = provider.delete(:data_providers)
        dpDataAll = []
        if dps.present?
          dps.each do |dp|
            dpDataAll << {
              count: number_with_delimiter(dp[:count]),
              val: dp[:text],
              foldable_url: dp[:url],
              foldable_link: true
            }
          end
          provider[:fields] = dpDataAll
        end
      end
      @providers
    end
  end
end
