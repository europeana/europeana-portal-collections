class Cache::RecordCountsJob < ActiveJob::Base
  queue_as :default

  def perform
    sets.each_pair do |key, set_params|
      params = set_params.merge(rows: 0, profile: 'minimal')
      count = repository.search(params).total

      cache_key = "record/counts/#{key}"
      Rails.cache.write(cache_key, count)
    end
  end

  protected

  def sets
    {
      all: { query: '*:*' }
    }.tap do |sets|
      music_channel_params = Channel.find('music').config[:params]
      %w(IMAGE SOUND TEXT VIDEO 3D).each do |type|
        sets["channels/music/type/#{type.downcase}"] = music_channel_params.merge(query: "TYPE:#{type}")
      end
    end
  end

  def blacklight_config
    @blacklight_config ||= PortalController.new.blacklight_config
  end

  def repository
    @repository ||= repository_class.new(blacklight_config)
  end

  def repository_class
    blacklight_config.repository_class
  end
end
