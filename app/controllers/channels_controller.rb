##
# Provides Blacklight search and browse, within a content Channel
class ChannelsController < ApplicationController
  include Catalog
  include Channels
  include Europeana::Styleguide

  before_action :redirect_to_root, only: :show, if: proc { params[:id] == 'home' }

  caches_action :show,
    if: Proc.new { !request.format.json? },
    expires_in: 1.hour,
    cache_path: Proc.new { I18n.locale.to_s + request.original_fullpath }

  def index
    redirect_to_root
  end

  def show
    @channel = find_channel
    @landing_page = find_landing_page
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

  def find_channel
    Channel.find_by_key!(params[:id]).tap do |channel|
      authorize! :show, channel
    end
  end

  def find_landing_page
    Page::Landing.find_or_initialize_by(slug: "channels/#{@channel.key}").tap do |landing_page|
      authorize! :show, landing_page
    end
  end

  ##
  # Gets from the cache the number of items of each media type within the current channel
  def channel_stats
    # ['EDM value', 'i18n key']
    types = [['IMAGE', 'images'], ['TEXT', 'texts'], ['VIDEO', 'moving-images'],
             ['3D', '3d'], ['SOUND', 'sound']]
    channel_stats = types.map do |type|
      type_count = Rails.cache.fetch("record/counts/channels/#{@channel.key}/type/#{type[0].downcase}")
      {
        count: type_count,
        text: t(type[1], scope: 'site.channels.data-types'),
        url: channel_path(q: "TYPE:#{type[0]}")
      }
    end
    channel_stats.reject! { |stats| stats[:count] == 0 }
    channel_stats.sort_by { |stats| stats[:count] }.reverse
  end

  def recent_additions
    Rails.cache.fetch("record/counts/channels/#{@channel.key}/recent-additions") || []
  end
end
