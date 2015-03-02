module Europeana
  ##
  # A Europeana document as returned by {RSolr::Europeana}
  class Document
    include Blacklight::Solr::Document

    attr_writer :provider_id, :record_id
    attr_reader :hierarchy

    def initialize(source_doc = {}, solr_response = nil)
      @hierarchy = source_doc.delete('hierarchy')
      super
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

    def as_json(options = nil)
      super.merge('hierarchy' => @hierarchy.as_json(options))
    end
  end
end
