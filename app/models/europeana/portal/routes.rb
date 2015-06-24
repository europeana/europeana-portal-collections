module Europeana
  module Portal
    ##
    # URL routing
    module Routes
      extend ActiveSupport::Concern

      included do |klass|
        klass.default_route_sets -= [:solr_document]
        unless klass.default_route_sets.include?(:europeana_document)
          klass.default_route_sets += [:europeana_document]
        end
      end

      def europeana_document(primary_resource)
        add_routes do |options|
          args = { only: [:show] }
          args[:constraints] = options[:constraints] if options[:constraints]

          post 'record/*id/track', args.merge(to: "#{primary_resource}#track", as: 'track_document')
          get 'record/*id', args.merge(to: "#{primary_resource}#show", as: 'document')
        end
      end
    end
  end
end
