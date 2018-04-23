# frozen_string_literal: true

# ##
# For views needing to display the links into the UGC components, as well as the
# related sign-in/out links.
module UgcContentDisplayingView
  extend ActiveSupport::Concern

  protected

  def ugc_content(force = false)
    if force || (@collection&.accepts_ugc?)
      {
        base_1418_url: config.x.europeana_1914_1918_url,
        include_1418_nav: true
      }
    end
  end
end
