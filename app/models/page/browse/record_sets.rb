# frozen_string_literal: true

class Page
  module Browse
    class RecordSets < Page
      has_many :sets, through: :elements, source: :positionable,
                      source_type: 'Europeana::Record::Set'

      validates :title, presence: true

      accepts_nested_attributes_for :sets, allow_destroy: true

      store_accessor :config, :base_query, :set_query, :show_menu

      def show_menu?
        ActiveRecord::Type::Boolean.new.type_cast_from_user(show_menu)
      end

      def europeana_ids
        sets.map(&:europeana_ids).flatten.uniq
      end
    end
  end
end
