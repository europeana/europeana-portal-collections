##
# Provides Blacklight search and browse, within a content Channel
class ChannelsController < ApplicationController
  include Catalog
  include Channels
  include Europeana::Styleguide

  rescue_from Channels::Errors::NoChannelConfiguration, with: :channel_not_found

  before_action :redirect_to_root, only: :show, if: proc { params[:id] == 'home' }

  def index
    redirect_to_root
  end

  def show
    @channel ||= Channel.find(params[:id])
    @channel_entry = channel_entry(@channel)
    @channel_stats = channel_stats
    @recent_additions = recent_additions

    (@response, @document_list) = search_results(params, search_params_logic) if has_search_parameters?

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

  def channel_not_found
    render file: 'public/404.html', status: 404
  end

  def channel_entry(channel)
    (channel_content[:channel_entry] || []).tap do |entry_config|
      entry_config.each do |entry|
        entry.merge!(
          url: channel_path(channel.id, q: entry[:query]),
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
  # Gets from the cache the number of items of each media type within the current channel
  def channel_stats
    # ['EDM value', 'i18n key']
    types = [['IMAGE', 'images'], ['TEXT', 'texts'], ['VIDEO', 'moving-images'],
             ['3D', '3d'], ['SOUND', 'sound']]
    channel_stats = types.map do |type|
      type_count = Rails.cache.fetch("record/counts/channels/#{@channel.id}/type/#{type[0].downcase}")
      {
        count: type_count,
        text: t(type[1], scope: 'site.channels.data-types'),
        url: channel_path(q: "TYPE:#{type[0]}")
      }
    end
    channel_stats.reject! { |stats| stats[:count] == 0 }
    channel_stats.sort_by { |stats| stats[:count] }.reverse
  end

  def channel_content
    @channel ? @channel.config[:content] || {} : {}
  end

  def recent_additions
    Rails.cache.fetch("record/counts/channels/#{@channel.id}/recent-additions") || []
  end
end
