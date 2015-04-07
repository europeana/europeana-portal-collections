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

      def id
        self[self.class.unique_key]
      end

      def as_json(options = nil)
        super.merge('hierarchy' => @hierarchy.as_json(options))
      end

      def has?(k, *values)
        keys = split_edm_key(k)
        return super unless keys.size > 1

        if values.present?
          fail NotImplementedError, "#{self.class}#has? with nested EDM key does not check for values"
        end

        !get(k, default: nil).nil?
      end

      def get(key, opts = { sep: ', ', default: nil })
        keys = split_edm_key(key)
        return opts[:default] unless key?(keys.first)

        target = self
        keys.each do |k|
          target = get_edm_child(target, k) unless target.nil?
        end

        val = get_localized_edm_value(target)
        
        if val.is_a?(Array)
          val = val.compact.flatten
          if opts[:sep]
            return val.join(opts[:sep])
          end
        end

        val
      end

      # BL expects document to respond to MLT method
      # @todo Remove once BL expectation loosened, or; implement if Europeana
      #   API supports it
      def more_like_this
        []
      end

      protected

      def split_edm_key(key)
        key.to_s.split('.')
      end

      def get_localized_edm_value(val)
        if val.is_a?(Array)
          val.collect do |v|
            get_localized_edm_value(v)
          end
        elsif val.is_a?(Hash)
          if val.key?(I18n.locale)
            val[I18n.locale]
          elsif val.key?(:def)
            val[:def]
          else
            val.values
          end
        else
          val
        end
      end

      def get_edm_child(parent, child_key)
        if parent.is_a?(Array)
          child = []
          parent.compact.each do |v|
            if v[child_key].is_a?(Array)
              child = child + v[child_key]
            elsif v.key?(child_key)
              child << v[child_key]
            end
          end
          child
        elsif parent.respond_to?(:'[]')
          parent[child_key]
        end
      end
    end
  end
end
