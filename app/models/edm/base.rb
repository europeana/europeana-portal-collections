# frozen_string_literal: true

module EDM
  class Base < OpenStruct
    class << self
      def registry_entries
        @registry_entries ||= begin
          YAML.load_file(File.join(Rails.root, 'config', "#{to_s.underscore}.yml"))
        end
      end

      def registry
        @registry ||= begin
          registry_entries.map do |id, attrs|
            new({ id: id.to_sym }.merge(attrs || {}))
          end
        end
      end
    end
  end
end
