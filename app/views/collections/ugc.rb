module Collections
  class Ugc < ApplicationView
    include BrowsableView
    include BrowseEntryDisplayingView
    include FacetEntryPointDisplayingView
    include HeroImageDisplayingView
    include NewsworthyView
    include PromotionLinkDisplayingView
    include SearchableView


    def page_title
      'Test 14-18 Story Submit'
    end


    def content
      {
        iframe_page: 'url here'
      }          
    end


  end
end
