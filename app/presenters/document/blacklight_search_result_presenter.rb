# frozen_string_literal: true

module Document
  # Presenter for a Blacklight document search result presenter
  class BlacklightSearchResultPresenter < SearchResultPresenter
    include BlacklightDocumentPresenter

    def rank
      document.rank
    end
  end
end
