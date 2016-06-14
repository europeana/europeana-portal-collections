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
  def within_collection?(localized_params = params)
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
    url = Cache::FeedJob::URLS[:tumblr][key]
    feed = cached_feed(url)
    return nil if feed.blank? || feed.entries.blank?

    paginated_items = Kaminari.paginate_array(feed.entries).page(page).per(per_page)

    {
      title: 'Tumblr',
      more_items_load: paginated_items.last_page? ? nil : tumblr_collection_path(id: key, format: :json),
      more_items_total: paginated_items.total_count,
      items: paginated_items.map do |item|
        {
          url: CGI.unescapeHTML(item.url),
          img: {
            src: feed_entry_img_src(item),
            alt: item.title
          },
          title: false
        }
      end
    }
  end
end
