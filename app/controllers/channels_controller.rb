##
# Provides Blacklight search and browse, within a content Channel
class ChannelsController < ApplicationController
  include Europeana::Catalog
  include Europeana::Channels
  include Europeana::Styleguide
  include BlogFetcher

  rescue_from Channels::Errors::NoChannelConfiguration, with: :channel_not_found

  before_action :find_channel, only: :show
  before_action :redirect_to_root, only: :show, if: proc { params[:id] == 'home' }
  before_action :fetch_blog_items, only: :show
  before_action :populate_channel_entry, only: :show, unless: :has_search_parameters?

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
    @channel ||= Channel.find(params[:id])
  end

  def channel_not_found
    render file: 'public/404.html', status: 404
  end

  def populate_channel_entry
    @channel_entry = (@channel.config[:channel_entry] || []).tap do |entry_config|
      entry_config.each do |entry|
        entry.merge!(
          url: channel_path(@channel.id, q: entry[:query]),
          # uncomment next line to add dynamic item counts
          # count: channel_entry_count(entry[:query])
        )
      end
    end
  end

  def channel_entry_count(entry_query)
    api_query = search_builder(self.search_params_logic).
      with(q: entry_query).query.
      merge(rows: 0, start: 1, profile: 'minimal')
    repository.search(api_query).total
  end
end
