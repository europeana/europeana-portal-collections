module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior
  
  # Override default from Blacklight::BlacklightHelperBehavior
  # per pull request https://github.com/projectblacklight/blacklight/pull/1064
  # @todo Remove entire file when fixed upstream
  def render_document_heading(*args)
    options = args.extract_options!
    if args.first.is_a? blacklight_config.solr_document_model
      document = args.shift
      tag = options[:tag]
    else
      document = nil
      tag = args.first || options[:tag]
    end

    tag ||= :h4

    content_tag(tag, presenter(document).document_heading, :itemprop => "name")
  end
end
