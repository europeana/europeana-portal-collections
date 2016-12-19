# frozen_string_literal: true
module Document
  ##
  # Presenter for a search result
  class SearchResultPresenter < DocumentPresenter
    include ActionView::Helpers::TextHelper
    include ApiHelper

    def initialize(document, response, controller, configuration = controller.blacklight_config)
      super(document, controller, configuration)
      @response = response
    end

    ##
    # Constructs a hash of data to render a search result for one document
    #
    # @param response [Europeana::Blacklight::Response]
    # @return [Hash]
    def content
      {
        object_url: document_path(@document, format: 'html', q: params[:q], l: params_to_log),
        title: title,
        text: text,
        year: year,
        origin: origin,
        is_image: doc_type == 'IMAGE',
        is_audio: doc_type == 'SOUND',
        is_text: doc_type == 'TEXT',
        is_video: doc_type == 'VIDEO',
        img: img,
        agent: agent_label,
        concepts: concept_labels,
        item_type: item_type
      }
    end

    def doc_type
      @doc_type ||= @document.fetch(:type, nil)
    end

    def field_value(fields, **options)
      unescape = options[:unescape]

      [fields].flatten.each do |field|
        value = render_index_field_value(field, options.except(:unescape))
        value = CGI.unescapeHTML(value.to_str) if unescape
        return value unless value.blank?
      end

      nil
    end

    def title
      truncate(field_value(%w(dcTitleLangAware title), unescape: true),
               length: 225,
               separator: ' ',
               escape: false)
    end

    def text
      {
        medium: truncate(field_value(%w(dcDescriptionLangAware dcDescription), unescape: true),
                         length: 277,
                         separator: ' ',
                         escape: false)
      }
    end

    def year
      {
        long: field_value(:year)
      }
    end

    def origin
      {
        text: field_value('dataProvider'),
        url: field_value('edmIsShownAt')
      }
    end

    def img
      {
        src: thumbnail_url,
        alt: ''
      }
    end

    def item_type
      {
        name: doc_type.nil? ? nil : t('site.results.list.product-' + doc_type.downcase.sub('_3d', '3D'))
      }
    end

    protected

    def thumbnail_url
      edm_preview = field_value('edmPreview')
      return nil if edm_preview.blank?

      api_uri ||= URI.parse(api_url)

      uri = URI.parse(edm_preview)
      query = Rack::Utils.parse_query(uri.query)
      query['size'] = 'w400'

      uri.scheme = api_uri.scheme
      uri.host = api_uri.host
      uri.path = api_uri.path + '/v2/thumbnail-by-url.json'
      uri.query = query.to_query

      uri.to_s
    end

    def agent_label
      field_value('edmAgentLabelLangAware') || field_value('edmAgentLabel') || field_value('dcCreator')
    end

    def concept_labels
      labels = @document.fetch('edmConceptPrefLabelLangAware', []) || []
      return nil if labels.is_a?(Hash)
      {
        items: labels[0..3].map { |c| { text: c } }
      }
    end

    def params
      controller.params
    end

    def params_to_log
      {
        p: params.slice(:q, :f, :mlt, :range),
        r: @document.rank,
        t: @response.total
      }
    end
  end
end
