module EDM
  class Base < OpenStruct
    class << self
      def registry
        @registry ||= begin
          entries = YAML.load_file(File.join(Rails.root, 'config', "#{to_s.underscore}.yml"))
          entries.map do |id, attrs|
            new({ id: id.to_sym }.merge(attrs || {}))
          end
        end
      end
    end
  end
end
