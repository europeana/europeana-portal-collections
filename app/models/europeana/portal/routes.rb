module Europeana
  module Portal
    ##
    # URL routing
    module Routes
      extend ActiveSupport::Concern

      included do |klass|
        klass.default_route_sets -= [:solr_document]
        klass.default_route_sets += [:europeana_document]
      end

      def europeana_document(primary_resource)
        add_routes do |options|
          args = {only: [:show]}
          args[:constraints] = options[:constraints] if options[:constraints]

          get 'record/:provider_id/:record_id', args.merge(to: "#{primary_resource}#show", as: 'document')
          post 'record/:provider_id/:record_id/track', args.merge(to: "#{primary_resource}#track", as: 'track_document')
        end
      end
    end
  end
end
