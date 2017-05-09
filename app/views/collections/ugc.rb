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
          }
      ]
    end

    def page_title
      'Europeana - First World War'
    end


    def content
      {
        base_1418_url: Rails.application.config.x.europeana_1914_1918_url
      }          
    end

  end
end
