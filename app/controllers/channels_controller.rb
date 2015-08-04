##
# Provides Blacklight search and browse, within a content Channel
class ChannelsController < ApplicationController
  include Catalog
  include Channels
  include Europeana::Styleguide
  include BlogFetcher

  rescue_from Channels::Errors::NoChannelConfiguration, with: :channel_not_found

  before_action :find_channel, only: :show
  before_action :redirect_to_root, only: :show, if: proc { params[:id] == 'home' }
  before_action :fetch_blog_items, only: :show
  before_action :populate_channel_entry, only: :show, unless: :has_search_parameters?
  before_action :populate_channel_stats, only: :show, unless: :has_search_parameters?
  before_action :populate_recent_additions, only: :show, unless: :has_search_parameters?

  def index
    redirect_to_root
  end

  def show
    respond_to do |format|
      format.html do
        render has_search_parameters? ? { template: '/portal/index' } : { action: 'show' }
      end
      format.rss { render 'catalog/index', layout: false }
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

  def find_channel
    @channel ||= Channel.find(params[:id])
  end

  def channel_not_found
    render file: 'public/404.html', status: 404
  end

  def populate_channel_entry
    @channel_entry = (channel_content[:channel_entry] || []).tap do |entry_config|
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

  ##
  # Gets from the API the number of items of each media type within the current channel
  def populate_channel_stats
    # ['EDM value', 'i18n key']
    types = [['IMAGE', 'images'], ['TEXT', 'texts'], ['VIDEO', 'moving-images'],
             ['3D', '3d'], ['SOUND', 'sound']]
    @channel_stats = types.map do |type|
      api_query = search_builder(self.search_params_logic).
        with(q: "TYPE:#{type[0]}").query.
        merge(rows: 0, start: 1, profile: 'minimal')
      type_count = repository.search(api_query).total
      {
        count: type_count,
        text: t(type[1], scope: 'site.channels.data-types'),
        url: channel_path(q: "TYPE:#{type[0]}")
      }
    end
    @channel_stats.reject! { |stats| stats[:count] == 0 }
    @channel_stats.sort_by! { |stats| stats[:count] }.reverse!
  end

  def channel_content
    @channel.config[:content] || {}
  end

  def populate_recent_additions
    @recent_additions = []

    time_now = Time.now
    month_now = time_now.month

    (0..2).each do |months_ago|
      time_from = Time.new(time_now.year, time_now.month) - months_ago.month
      time_to = time_from + 1.month - 1.second

      time_from_param = time_from.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
      time_to_param = time_to.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
      time_range_query = "timestamp_created:[#{time_from_param} TO #{time_to_param}]"

      api_query = search_builder(self.search_params_logic).
        with(q: time_range_query).query.
        merge(rows: 0, start: 1, profile: 'minimal facets')
      api_response = repository.search(api_query)
      next if api_response.total == 0

      data_provider_facet = api_response.facet_fields.find { |f| f['name'] == 'DATA_PROVIDER' }
      next if data_provider_facet.blank?

      data_provider_facet['fields'][0..2].each do |field|
        @recent_additions << {
          text: field['label'],
          number: field['count'],
          date: time_from.strftime('%B %Y'),
          url: channel_path(q: time_range_query, f: { 'DATA_PROVIDER' => [field['label']] })
        }
      end

      break if @recent_additions.size >= 3
    end

    @recent_additions = @recent_additions[0..2]
    @recent_additions.sort_by! { |addition| addition[:number] }.reverse!
  end
end
