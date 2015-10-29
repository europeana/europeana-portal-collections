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
end
