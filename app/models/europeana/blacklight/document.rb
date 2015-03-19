module Europeana
  module Blacklight
    ##
    # A Europeana document
    class Document
      include ::Blacklight::Document

      attr_writer :provider_id, :record_id
      attr_accessor :hierarchy

      def to_param
        "#{provider_id}/#{record_id}"
      end

      def provider_id
        @provider_id ||= id.to_s.split('/')[1]
      end

      def record_id
        @record_id ||= id.to_s.split('/')[2]
      end

      def as_json(options = nil)
        super.merge('hierarchy' => @hierarchy.as_json(options))
      end

      def has?(k, *values)
        return super unless k.include?('.')

        if values.present?
          fail NotImplementedError, "#{self.class}#has? with nested EDM key does not check for values"
        end

        keys = split_edm_key(k)
        return false unless super(keys.first)
        parent = self[keys.first]

        if parent.is_a?(Hash)
          parent.key?(keys.last)
        elsif parent.is_a?(Array)
          parent.any? { |c| c.is_a?(Hash) && c.key?(keys.last) }
        else
          false
        end
      end

      def get(key, opts = { sep: ', ', default: nil })
        keys = split_edm_key(key)
        return opts[:default] unless key?(keys.first)

        val = self[keys.first]
        val = get_edm_child(val, keys.last) if keys.size > 1
        val = get_localized_edm_value(val)

        val.compact!
        (val.is_a?(Array) && opts[:sep]) ? val.join(opts[:sep]) : val
      end

      def get_localized_edm_value(val)
        val = [val] unless val.is_a?(Array)
        val.collect do |v|
          if v.is_a?(Hash)
            if v.key?(I18n.locale)
              v[I18n.locale]
            elsif v.key?(:def)
              v[:def]
            else
              v
            end
          else
            v
          end
        end
      end

      def get_edm_child(parent, child_key)
        case parent
        when Array
          parent.collect { |v| v[child_key] }
        when Hash
          parent[child_key]
        end
      end

      def split_edm_key(key)
        keys = key.to_s.split('.')
        if keys.size > 2
          fail ArgumentError, "Too many levels of EDM key requested: max is 2; got #{keys.size}"
        end
        keys
      end

      # BL expects document to respond to MLT method
      # @todo Remove once BL expectation loosened, or; implement if Europeana
      #   API supports it
      def more_like_this
        []
      end
    end
  end
end
