# Rack::Rewrite rules
#
# Includes redirects for old portal query params to Rails/Blacklight equivalents
Rails.application.configure do
  config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
    # Redirect searches with old params to app's equivalents
    # @todo Move the logic into a class
    r301 %r{/search(.html)?(\?.*)},
      lambda { |match, rack_env|
        params = Rack::Utils.parse_query(rack_env['QUERY_STRING'])

        # Search query
        params['q'] = params.delete('query') if params.key?('query')

        # Search results per page
        rows = (params.delete('rows') || '24').to_i

        # Search results page, adjusted to new 12-per-page default
        if params.key?('start')
          start = params.delete('start').to_i
          unless start <= rows
            per_page = (params['per_page'] || '12').to_i
            params['page'] = ((start - 1) / per_page) + 1
          end
        end

        # Facet params
        if params.key?('qf')
          bl_facets = PortalController.blacklight_config.facet_fields.keys
          [params['qf']].flatten.each do |qf|
            if qf.include?(':')
              field, value = qf.split(':')
              if bl_facets.include?(field)
                params['f'] ||= {}
                params['f'][field] ||= []
                params['f'][field] << value
                if params['qf'].is_a?(Array)
                  params['qf'].delete(qf)
                  params.delete('qf') if params['qf'].blank?
                else
                  params.delete('qf')
                end
              end
            end
          end
        end

        query = Rack::Utils.build_nested_query(params)
        Europeana::Portal::Application.config.relative_url_root + '/search?' + query
      },
      if: Proc.new { |rack_env|
        (Rack::Utils.parse_query(rack_env['QUERY_STRING']).keys & %w(query rows start qf)).present?
      }
  end
end
