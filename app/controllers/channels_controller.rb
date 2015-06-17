##
# Provides Blacklight search and browse, within a content Channel
class ChannelsController < ApplicationController
  include Europeana::Catalog
  include Europeana::Channels
  include Europeana::Styleguide
  include BlogFetcher

  rescue_from Channels::Errors::NoChannelConfiguration, with: :channel_not_found

  before_filter :find_channel, only: :show
  before_filter :redirect_to_root, only: :show, if: proc { params[:id] == 'home' }
  before_filter :fetch_blog_items, only: :show

  def index
    redirect_to_root
  end

  def show
    respond_to do |format|
      format.html { render show_html_template }
      format.rss  { render 'catalog/index', layout: false }
      format.atom { render 'catalog/index', layout: false }
      format.json { render json: render_search_results_as_json }

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  protected

  def _prefixes
    @_prefixes_with_partials ||= super | %w(catalog)
  end

  def start_new_search_session?
    has_search_parameters?
  end

  def show_html_template
    'templates/Search/' + (has_search_parameters? ? 'Search-results-list' : 'Channels-landing')
  end

  def find_channel
    id = (params[:action] == 'index' ? :home : params[:id].to_sym)
    @channel ||= Channel.find(id)
  end

  def channel_not_found
    render file: 'public/404.html', status: 404
  end
end
