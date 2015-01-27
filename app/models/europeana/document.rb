module Europeana
  class Document
    include Blacklight::Solr::Document
    
    def to_param
      "#{provider_id}/#{record_id}"
    end
    
    def provider_id
      @provider_id ||= id.to_s.split('/')[1]
    end
    
    def record_id
      @record_id ||= id.to_s.split('/')[2]
    end
    
    def cache_key
      "#{provider_id}/#{record_id}-#{self['timestamp_update_epoch']}"
    end
  end
end
