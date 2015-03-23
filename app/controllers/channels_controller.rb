##
# Provides Blacklight search and browse, within a content Channel
class ChannelsController < ApplicationController
  include Europeana::Catalog

  configure_blacklight do |config|
    config.search_builder_class = Europeana::Blacklight::SearchBuilder::Channels
  end
  search_params_logic << :add_channel_qf_to_api

  before_filter :find_channel, only: [:index, :show]
  before_filter :redirect_show_home_to_index, only: :show
      
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
      (@channel.id == :home) ? 'index' : 'show'
    end
  end

  def find_channel
    id = (params[:action] == 'index' ? :home : params[:id].to_sym)
    @channel ||= Channel.find(id)
  end

  def redirect_show_home_to_index
    redirect_to action: :index && return if params[:id] == 'home'
  end
end
