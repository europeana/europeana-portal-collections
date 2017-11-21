# frozen_string_literal: true

module Document
  ##
  # Presenter for a search result
  class SearchResultPresenter < ApplicationPresenter
    include ActionView::Helpers::TextHelper
    include ApiHelper
    include BlacklightDocumentPresenter
    include Metadata::Rights
    include ThumbnailHelper

    attr_reader :document, :controller

    # @param response [Europeana::Blacklight::Response]
    def initialize(document, controller, response = nil)
      @document = document
      @controller = controller
      @response = response
    end

    ##
    # Constructs a hash of data to render a search result for one document
    #
    # @return [Hash]
    def content
      {
        object_url: controller.document_path(@document, format: 'html', q: params[:q], l: params_to_log),
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
      super(fields, options.merge(context: :index))
    end

    def title
      truncate(field_value(%w(dcTitleLangAware title)),
               length: 225,
               separator: ' ',
               escape: false)
    end

    def text
      {
        medium: truncate(field_value(%w(dcDescriptionLangAware dcDescription)),
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

    def thumbnail_url(generic: false)
      thumbnail_url_for_edm_preview(field_value('edmPreview'), generic: generic, type: doc_type)
    end

    def media_rights
      @media_rights ||= field_value('rights')
    end

    protected

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
        t: @response.nil? ? nil : @response.total
      }
    end
  end
end
