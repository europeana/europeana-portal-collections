module Europeana
  class Document
    include Blacklight::Solr::Document
    
    attr_reader :hierarchy
    
    def initialize(*args)
      super
      load_hierarchy
    end
    
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
    
    def load_hierarchy
      record = Europeana::Record.new(self.id)
      ancestor_self_siblings = record.ancestor_self_siblings
      
      @hierarchy = {
        'self' => ancestor_self_siblings['self'],
        'ancestors' => ancestor_self_siblings['ancestors'],
        'following-siblings' => ancestor_self_siblings['following-siblings']
      }
    rescue Europeana::Errors::RequestError => error
      if error.message == "This record has no hierarchical structure!"
        @hierarchy = false
      else
        raise
      end
    end
  end
end
