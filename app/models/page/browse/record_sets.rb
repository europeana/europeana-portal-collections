# frozen_string_literal: true

class Page
  module Browse
    class RecordSets < Page
      has_many :sets, through: :elements, source: :positionable,
                      source_type: 'Europeana::Record::Set'

      validates :title, presence: true

      accepts_nested_attributes_for :sets, allow_destroy: true
      has_settings :base_query, :set_query

      def europeana_ids
        sets.map(&:europeana_ids).flatten.uniq
      end
    end
  end
end
