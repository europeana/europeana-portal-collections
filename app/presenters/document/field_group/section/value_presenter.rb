# frozen_string_literal: true

module Document
  module FieldGroup
    module Section
      ##
      # Presenter for one value of a metadata field
      #
      # TODO: should this be sub-classed? e.g. for single string values, language
      #   maps, entity-linked values
      class ValuePresenter < ApplicationPresenter
        include BlacklightDocumentPresenter
        include DateHelper
        include EntitiesHelper
        include UrlHelper

        attr_reader :document, :controller, :section, :content, :field, :entity
        delegate :blank?, :nil?, :present?, :empty?, to: :text

        # @param document [Europeana::Blacklight::Document]
        # @param controller [ActionController::Base]
        # @param section [Document::FieldGroup::SectionPresenter]
        # @param field [String,Symbol]
        # @param content [String]
        # @param entity [Europeana::Blacklight::Document]
        def initialize(document, controller, section, field, content, entity = nil)
          @document = document
          @controller = controller
          @section = section
          @field = field
          @content = content
          @entity = entity
        end

        def display
          {
            text: text,
            url: url,
            ga_data: section.ga_data,
            extra_info: extra_info,
            raw: section.html_line_breaks?,
            json_url: entity_url('json'),
            entity: for_entity?,
            europeana_entity: europeana_entity?
          }
        end

        def extra_info
          return nil unless for_entity? && section.entity_extra.present?
          return nil unless entity.present?
          EntityPresenter.new(entity, controller).extra(section.entity_extra)
        end

        def for_entity?
          entity.present?
        end

        def url
          if linkable_for_entity?
            url = entity_url
            return url unless url.nil?
          end

          return search_path if section.search_field.present?

          linkable_value? ? content : nil
        end

        def linkable_value?
          return false unless content.is_a?(String)
          content.start_with?('http://', 'https://')
        end

        def linkable_for_entity?
          for_entity? &&
            %w(agents concepts).include?(section.entity_name) # while only agent & concept entity pages are implemented
        end

        def entity_url(format = 'html')
          return nil unless europeana_entity?
          portal_entity_path(entity.fetch('about'), slug: entity_url_slug(entity), format: format)
        end

        def europeana_entity?
          return @europeana_entity if instance_variable_defined?(:@europeana_entity)
          @europeana_entity = for_entity? && europeana_entity_url?(entity.fetch('about'))
        end

        def search_path
          return nil if to_search.nil?

          controller.search_path(q: "#{section.search_field}:#{to_search}")
        end

        def to_search
          return nil unless content.is_a?(String)

          @search ||= begin
            if section.quoted?
              enquote_and_escape(content)
            else
              search = content.gsub(/[()\[\]<>]/, '')
              parenthesise_and_escape(search)
            end
          end
        end

        def text
          text = content.dup.to_s
          text = section.translate_value(text)
          text = text.titleize if text.present? && section.capitalised?
          text = format_date(text, section.format_date) if section.format_date?
          text = htmlify_line_breaks(text) if section.html_line_breaks?
          text
        end

        def htmlify_line_breaks(text)
          CGI.escapeHTML(text).gsub(/(\r\n|\r|\n)/, '<br/>').html_safe
        end

        def excluded?
          section.exclude_vals? && section.exclude_vals.include?(text)
        end
      end
    end
  end
end
