##
# Collections helpers
module CollectionsHelper
  include FeedHelper

  ##
  # Returns the keys of all {Collection}s
  #
  # @return [Array<String>]
  def available_collections
    Collection.all.map(&:key)
  end

  ##
  # Tests whether the current request is in the context of a {Collection}
  #
  # @return [Boolean]
  def within_collection?(localized_params = nil)
    localized_params ||= (request.respond_to?(:parameters) ? params : {})
    localized_params[:controller] == 'collections' &&
      localized_params[:id].present?
  end

  ##
  # Returns the current collection being viewed by the user
  #
  # @return [Collection]
  def current_collection
    return nil unless within_collection?
    Collection.find_by_key!(params[:id])
  end

  ##
  # Gets all collections that are published, and have an associated landing
  # page that is also published.
  #
  # @return [Array<Collection>]
  def displayable_collections
    @displayable_collections ||= Collection.published.select do |c|
      (c.key != 'all') && c.landing_page.present? && c.landing_page.published?
    end
  end

  def collection_tumblr_feed_content(collection, options = {})
    page = options[:page] || 1
    per_page = options[:per_page] || 12
    key = collection.key.underscore.to_sym
    options[:feed_job_url] = :tumblr
    items = collections_feed_items_for(collection, options)

    return nil if items.blank?

    paginated_items = Kaminari.paginate_array(items).page(page).per(per_page)
    {
      title: 'Tumblr',
      tumblr_url: Cache::FeedJob::URLS[:tumblr][key].sub('/rss', ''),
      more_items_load: paginated_items.last_page? ? nil : tumblr_collection_path(id: key, format: :json),
      more_items_total: paginated_items.total_count,
      items: items
    }
  end


  def collections_feed_items_for(collection, options = {})
    feed_job_urls_key =  options[:feed_job_url] || :blog
    key = collection.key.underscore.to_sym
    url = Cache::FeedJob::URLS[feed_job_urls_key][key]
    feed = cached_feed(url)

    return [] if feed.blank? || feed.entries.blank?

    feed.entries.map do |item|
      {
          url: CGI.unescapeHTML(item.url),
          img: {
              src: feed_entry_thumbnail_url(item),
              alt: item.title
          },
          title: item.title,
          date: I18n.l(item.published),
          excerpt: {
              short: ActionController::Base.helpers.strip_tags(CGI.unescapeHTML(item.summary))
          },
          type: feed_job_urls_key.to_s
      }
    end
  end



  def collection_feeds_content(collection, options = {})
    page = options[:page] || 1
    per_page = options[:per_page] || 12
    key = collection.key.underscore.to_sym

    options[:feed_job_url] = :tumblr
    tumblr_items = collections_feed_items_for(collection, options)
    options[:feed_job_url] = :blog
    news_items = collections_feed_items_for(collection, options)

    combined_items = tumblr_items + news_items
    combined_items.sort_by! { |item| item[:date] }
    combined_items.reverse!

    return nil if combined_items.blank?

    paginated_items = Kaminari.paginate_array(combined_items).page(page).per(per_page)

    content = {
      title: false,
      tumblr_url: Cache::FeedJob::URLS[:tumblr][key].sub('/rss', ''),
      more_items_load: paginated_items.last_page? ? nil : tumblr_collection_path(id: key, format: :json),
      more_items_total: paginated_items.total_count,
      items: paginated_items
    }
  end

  def clicktip
    key = current_collection.key.underscore.to_sym
    {
      activator: '.show-feeds',
      direction: 'top',
      has_tooltip_links: true,
      tooltip_links: [
        {
          text: 'tumblr',
          url: Cache::FeedJob::URLS[:tumblr][key]
        },
        {
          text: 'news',
          url: Cache::FeedJob::URLS[:blog][key]
        }
      ]
    }
  end

  def beta_collection?(collection)
    collection.key == 'fashion'
  end
end
