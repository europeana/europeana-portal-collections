module EDM
  class Base < OpenStruct
    class << self
      attr_reader :registry

      def load(entries)
        @registry = begin
          entries.map do |id, attrs|
            new({ id: id.to_sym }.merge(attrs || {}))
          end
        end
      end
    end
  end
end
