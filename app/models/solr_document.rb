# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document
  
  field_semantics.merge!(    
                         :title => "title",
                         :author => "author_display",
                         :language => "language_facet",
                         :format => "type"
                         )

  # self.unique_key = 'id'
  
  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Solr::Document::Email)
  
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Solr::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Solr::Document::DublinCore)
  
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
