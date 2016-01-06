##
# Collections helpers
module CollectionsHelper
  def available_collections
    Collection.all.map(&:key)
  end

  def within_collection?(localized_params = params)
    localized_params['controller'] == 'collections' &&
      localized_params['id'].present?
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
  # Returns the collection the current search was performed in
  #
  # @return [Collection]
  def current_search_collection
    return nil unless current_search_session.query_params[:id]
    Collection.find_by_key!(current_search_session.query_params[:id])
  end
end
