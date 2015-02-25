module Europeana
  ##
  # A Europeana document as returned by {RSolr::Europeana}
  class Document
    include Blacklight::Solr::Document

    attr_writer :provider_id, :record_id
    attr_reader :hierarchy

    def to_param
      "#{provider_id}/#{record_id}"
    end

    def provider_id
      @provider_id ||= id.to_s.split('/')[1]
    end

    def record_id
      @record_id ||= id.to_s.split('/')[2]
    end

    def load_hierarchy
      record = Europeana::Record.new(id)
      @hierarchy = record.hierarchy('ancestor-self-siblings')

      if @hierarchy['self']['hasChildren']
        @hierarchy = record.hierarchy('ancestor-self-siblings', :children)
      end
    rescue Europeana::Errors::RequestError => error
      if error.message == 'This record has no hierarchical structure!'
        @hierarchy = false
      else
        raise
      end
    end
  end
end
