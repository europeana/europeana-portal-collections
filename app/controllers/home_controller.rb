##
# Home page
class HomeController < ApplicationController
  include Catalog
  include Europeana::Styleguide

  caches_action :index,
    expires_in: 1.hour,
    cache_path: Proc.new { I18n.locale.to_s + request.original_fullpath }

  # GET /
  def index
    @channel = find_channel
    @landing_page = find_landing_page
    @europeana_item_count = Rails.cache.fetch('record/counts/all') # populated by {RecordCountsCacheJob}

    respond_to do |format|
      format.html
    end
  end

  protected

  def find_channel
    Channel.find_or_initialize_by(key: 'home').tap do |channel|
      authorize! :show, channel
    end
  end

  def find_landing_page
    Page::Landing.find_or_initialize_by(slug: '').tap do |landing_page|
      authorize! :show, landing_page
    end
  end
end
