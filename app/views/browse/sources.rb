module Browse
  class Sources < ApplicationView
    def page_title
      t('site.browse.sources.title')
    end

    def content
      {
        title: page_title,
        providers: @providers.blank? ? nil : {
          title: page_title,
          items: stylised_providers
        }
      }
    end

    def head_meta
      [
        { meta_name: 'description', content: page_title }
      ] + super
    end

    protected

    def stylised_providers
      @providers.each do |provider|
        provider[:count] = number_with_delimiter(provider[:count])
        dps = provider.delete(:data_providers)
        if dps.present?
          dps.each do |dp|
            dp[:count] = number_with_delimiter(dp[:count])
          end
          provider[:data_providers] = {
            items: dps
          }
        end
      end
    end
  end
end
