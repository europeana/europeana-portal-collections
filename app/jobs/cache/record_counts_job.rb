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
      Channel.published.each do |channel|
        %w(IMAGE SOUND TEXT VIDEO 3D).each do |type|
          sets["channels/#{channel}/type/#{type.downcase}"] = { overlay: channel.api_params_hash }.merge(query: "TYPE:#{type}")
        end
      end
    end
  end
end
