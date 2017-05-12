# frozen_string_literal: true
# ##
# For views needing to display the links into the UGC components, as well as the related sign-in/out links.
module UgcLinkDisplayingView
  extend ActiveSupport::Concern

  protected

  def content
    if @collection && @collection.key == 'firstworldwar'
      {
        base_1418_url: config.x.europeana_1914_1918_url,
        include_1418_nav: true
      }.reverse_merge(super)
    else
      super
    end
  end
end
