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
    @displayable_collections ||= Collection.published.order(:title).select do |c|
      (c.key != 'all') && c.landing_page.present? && c.landing_page.published?
    end
  end

  def clicktip
  end

  def beta_collection?(collection)
    # Uncomment this to indicate that a new collection is beta
    # collection.key == 'new-collection'
    false
  end
end
