module Collections
  class Ugc < ApplicationView
    include BrowsableView
    include BrowseEntryDisplayingView
    include FacetEntryPointDisplayingView
    include HeroImageDisplayingView
    include NewsworthyView
    include PromotionLinkDisplayingView
    include SearchableView

    def js_vars
      [
          {
              name: 'pageName', value: 'e7a_1418'
          },
          {
              name: 'iframe_page', value: Rails.application.config.x.europeana_1914_1918_url
          }
      ]
    end

    def page_title
      'Europeana - First World War'
    end


    def content
      {
        base_url: request.domain
      }          
    end


  end
end
