module EDM
  class Rights < OpenStruct
    class UnknownRights < StandardError; end

    def self.registry(permission = nil)
      @registry ||= begin
        rights = YAML.load_file(File.join(Rails.root, 'config', 'edm_rights.yml'))
        rights.map do |id, attrs|
          new({ id: id.to_sym }.merge(attrs))
        end
      end
    end

    def self.normalise(string)
      registry.each do |rights|
        return rights if string.match(rights.pattern)
      end
      fail UnknownRights, "Unknown rights: #{string}"
    end
  end
end
