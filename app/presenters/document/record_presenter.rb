# frozen_string_literal: true

module Document
  ##
  # Blacklight document presenter for a Europeana record
  class RecordPresenter < ApplicationPresenter
    include ActionView::Helpers::TextHelper
    include BlacklightDocumentPresenter
    include Entities
    include EntitiesHelper
    include Metadata::Rights

    attr_reader :document, :controller

    def initialize(document, controller)
      @document = document
      @controller = controller
    end

    def title
      @title ||= [display_title, creator_title].compact.join(' | ')
    end

    def display_title
      field_value('proxies.dcTitle') ||
        truncate(field_value('proxies.dcDescription'), length: 200, separator: ' ', escape: false)
    end

    def creator_title
      @creator_title ||= begin
        document.fetch('agents.prefLabel', []).first ||
          field_value('dcCreator') ||
          field_value('proxies.dcCreator')
      end
    end

    def edm_is_shown_at
      @edm_is_shown_at ||= aggregation.fetch('edmIsShownAt', nil)
    end

    # Get the actual provider's edm:isShownAt, extracted from our redirection API
    #
    # @return [String]
    def provider_edm_is_shown_at
      @provider_edm_is_shown_at ||= begin
        uri = URI.parse(edm_is_shown_at)
        Rack::Utils.parse_query(uri.query)['shownAt']
      end
    rescue URI::InvalidURIError
      nil
    end

    def edm_is_shown_by
      @edm_is_shown_by ||= aggregation.fetch('edmIsShownBy', nil)
    end

    def edm_object
      @edm_object ||= aggregation.fetch('edmObject', nil)
    end

    def edm_landing_page
      @edm_landing_page ||= field_value('europeanaAggregation.edmLandingPage')
    end

    def aggregation
      @first_aggregation ||= @document.aggregations.first
    end

    def is_shown_by_or_at
      edm_is_shown_by || edm_is_shown_at
    end

    def has_views
      @has_views ||= aggregation.fetch('hasView', []).compact
    end

    def edm_is_shown_by_web_resource
      @edm_is_shown_by_web_resource ||= begin
        web_resources.detect do |web_resource|
          web_resource.fetch('about', nil) == edm_is_shown_by
        end
      end
    end

    def web_resources
      @web_resources ||= begin
        aggregation.respond_to?(:webResources) ? aggregation.webResources : []
      end
    end

    def edm_object_thumbnails_edm_is_shown_by?
      edm_is_shown_by.present? && edm_object.present? && (edm_object != edm_is_shown_by)
    end

    def edm_object_thumbnails_has_view?
      edm_object.present? && has_views.include?(edm_object)
    end

    def media_web_resource_presenters
      return [] if web_resources.blank?

      @media_web_resource_presenters ||= begin
        salient_web_resources = web_resources.dup.tap do |web_resources|
          # make sure the edm_is_shown_by is the first item
          unless edm_is_shown_by_web_resource.nil?
            web_resources.unshift(web_resources.delete(edm_is_shown_by_web_resource))
          end
        end
        presenters = salient_web_resources.map do |web_resource|
          Document::WebResourcePresenter.new(web_resource, controller, document, self)
        end
        presenters.uniq(&:url)
      end
    end

    def displayable_media_web_resource_presenters
      @displayable_media_web_resource_presenters ||= media_web_resource_presenters.select(&:displayable?)
    end

    def media_web_resources(options = {})
      Kaminari.paginate_array(displayable_media_web_resource_presenters).
        page(options[:page]).per(options[:per_page])
    end

    def media_rights
      @media_rights ||= begin
        dc_rights = field_value('proxies.dcRights')
        if dc_rights.is_a?(String) && dc_rights.start_with?('http://rightsstatements.org/page/')
          dc_rights
        else
          field_value('aggregations.edmRights')
        end
      end
    end

    def field_group(id)
      Document::FieldGroupPresenter.new(document, controller, id).display
    end
  end
end
