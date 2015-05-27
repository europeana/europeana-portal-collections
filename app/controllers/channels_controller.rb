##
# Provides Blacklight search and browse, within a content Channel
class ChannelsController < ApplicationController
  include Europeana::Catalog
  include Europeana::Styleguide

  rescue_from Channels::Errors::NoChannelConfiguration, with: :channel_not_found

  self.search_params_logic = Europeana::Blacklight::SearchBuilder.default_processor_chain +
    [:add_channel_qf_to_api]

  before_filter :find_channel, only: [:index, :show]
  before_filter :redirect_show_home_to_index, only: :show
  before_filter :count_all, only: :index, unless: :has_search_parameters?

  def index
    show
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
    %w(index show).include?(action_name)
  end

  def show_html_template
    if has_search_parameters?
      'templates/Search/Search-results-list'
    else
      (@channel.id == :home) ? 'templates/Search/Search-home' : 'templates/Search/Channels-landing'
    end
  end

  def find_channel
    id = (params[:action] == 'index' ? :home : params[:id].to_sym)
    @channel ||= Channel.find(id)
  end

  def channel_not_found
    render file: 'public/404.html', status: 404
  end

  def redirect_show_home_to_index
    if params[:id] == 'home'
      redirect_to action: :index
      return false
    end
  end

  ##
  # Gets the total number of items available over the Europeana API
  def count_all
    all_params = { query: '*:*', rows: 0, profile: 'minimal' }
    @europeana_item_count = repository.search(all_params).total
  end
end
