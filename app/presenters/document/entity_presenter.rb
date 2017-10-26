# frozen_string_literal: true

module Document
  ##
  # Presenter for an entity on an item page
  class EntityPresenter < ApplicationPresenter
    attr_reader :entity

    def initialize(entity)
      @entity = entity
    end

    def label
      pref_label || foaf_name || timespan_begin_end || alt_label || entity[:about]
    end

    def potential_labels
      [pref_label, foaf_name, timespan_begin_end, alt_label, entity[:about]].flatten
    end

    def alt_label
      entity.fetch('altLabel', nil)
    end

    def pref_label
      entity.fetch('prefLabel', nil)
    end

    def foaf_name
      entity.fetch('foafName', nil)
    end

    def timespan_begin_end
      begin_and_end = [entity.fetch('begin', nil), entity.fetch('end', nil)].compact
      begin_and_end.blank? ? nil : [begin_and_end.join('–')]
    end
  end
end
