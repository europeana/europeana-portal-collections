class CatalogController < ApplicationController  
  include Blacklight::Catalog
  include ChannelsBlacklightConfig
  include EuropeanaBlacklightAdapter
end
