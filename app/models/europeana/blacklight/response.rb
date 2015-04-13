module Europeana
  module Blacklight
    ##
    # Europeana API response for BL
    class Response < HashWithIndifferentAccess
      require 'europeana/blacklight/response/pagination'
      require 'europeana/blacklight/response/facets'
      require 'europeana/blacklight/response/more_like_this'

      include Pagination
      include Facets
      include MoreLikeThis

      attr_reader :request_params
      attr_accessor :document_model, :blacklight_config

      def initialize(data, request_params, options = {})
        super(force_to_utf8(data))
        @request_params = request_params
        self.document_model = options[:document_model] || Document
        self.blacklight_config = options[:blacklight_config]
      end

      def update(other_hash)
        other_hash.each_pair { |key, value| self[key] = value }
        self
      end

      def params
        self['params'] ? self['params'] : request_params
      end

      def rows
        params[:rows].to_i
      end

      def sort
        params[:sort]
      end

      def docs
        @docs ||= begin
          self['items'] || []
        end
      end

      def documents
        docs.collect { |doc| document_model.new(doc, self) }
      end

      def grouped
        []
      end

      def group(_key)
        nil
      end

      def grouped?
        false
      end

      def export_formats
        documents.map { |x| x.export_formats.keys }.flatten.uniq
      end

      def total
        self[:totalResults].to_s.to_i
      end

      def start
        params[:start].to_s.to_i - 1
      end

      def empty?
        total == 0
      end

      private

      def force_to_utf8(value)
        case value
        when Hash
          value.each { |k, v| value[k] = force_to_utf8(v) }
        when Array
          value.each { |v| force_to_utf8(v) }
        when String
          value.force_encoding('utf-8') if value.respond_to?(:force_encoding)
        end
        value
      end
    end
  end
end
