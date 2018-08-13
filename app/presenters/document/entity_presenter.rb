# frozen_string_literal: true

module Document
  ##
  # Presenter for an entity on an item page
  class EntityPresenter < ApplicationPresenter
    include BlacklightDocumentPresenter
    include DateHelper

    attr_reader :document, :controller

    def initialize(document, controller)
      @document = document
      @controller = controller
    end

    def label
      pref_label || foaf_name || timespan_begin_end || alt_label || document[:about]
    end

    def potential_labels
      [pref_label, foaf_name, timespan_begin_end, alt_label, document[:about]].flatten
    end

    def alt_label
      document.fetch('altLabel', nil)
    end

    def pref_label
      document.fetch('prefLabel', nil)
    end

    def foaf_name
      document.fetch('foafName', nil)
    end

    def timespan_begin_end
      begin_and_end = [document.fetch('begin', nil), document.fetch('end', nil)].compact
      begin_and_end.blank? ? nil : [begin_and_end.join('–')]
    end

    # Extracts extra field values to display for this entity
    #
    # @param extras [Array<Hash>] Extra fields as defined in
    #   `config/record_field_groups.yml`
    # @return [Hash]
    def extra(extras)
      {}.tap do |hash|
        extras.each do |extra|
          val = document.fetch(extra[:field], nil)
          val = render_field_value(val)
          next unless val.present?

          context = extra_nested_context(extra, hash)

          context[:scope][context[:key]] = if extra[:format_date].present?
                                             format_date(val, extra[:format_date])
                                           else
                                             val
                                           end
        end
      end
    end

    def extra_nested_context(extra, context)
      keys = (extra[:map_to] || extra[:field]).split('.')
      last = keys.pop

      keys.each do |k|
        context[k.to_sym] ||= {}
        context = context[k.to_sym]
      end

      { key: last.to_sym, scope: context }
    end
  end
end
