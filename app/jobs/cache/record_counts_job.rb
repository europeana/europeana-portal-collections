class Cache::RecordCountsJob < ActiveJob::Base
  include ApiQueryingJob

  queue_as :default

  def perform
    sets.each_pair do |key, set_params|
      builder = search_builder(search_params_logic)
      query = builder.rows(0).where(set_params[:query]).with_overlay_params(set_params[:overlay] || {}).merge(profile: 'minimal')
      count = repository.search(query).total
      cache_key = "record/counts/#{key}"
      Rails.cache.write(cache_key, count)
    end
  end

  protected

  def sets
    {
      all: { query: '*:*' }
    }.tap do |sets|
      Collection.published.each do |collection|
        %w(IMAGE SOUND TEXT VIDEO 3D).each do |type|
          sets["collections/#{collection.key}/type/#{type.downcase}"] = { overlay: collection.api_params_hash }.merge(query: "TYPE:#{type}")
        end
      end
    end
  end
end
