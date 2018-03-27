# frozen_string_literal: true

# Rack::Rewrite rules
#
# Includes redirects for old portal query params to Rails/Blacklight equivalents
Rails.application.configure do
  config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
    # Redirect searches with old params to app's equivalents
    # @todo Move the logic into a class
    r301 %r{^/search.html\?},
         lambda { |_match, rack_env|
           params = Rack::Utils.parse_query(rack_env['QUERY_STRING'], '&')
           # Search query
           if params.key?('query')
             params['q'] = params.delete('query').force_encoding('ISO-8859-1').encode('UTF-8')
           end
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
               next unless qf.include?(':')
               field, value = qf.split(':')
               next unless bl_facets.include?(field)
               if value[0] == '"' && value[-1] == '"'
                 value = value[1..-2]
               end
               params['f'] ||= {}
               params['f'][field] ||= []
               params['f'][field] << value
               if params['qf'].is_a?(Array)
                 params['qf'].delete(qf)
               else
                 params.delete('qf')
               end
             end
             if params.key?('qf')
               params['qf'] = [params['qf']].flatten
               params['qf'] = params['qf'].map do |qf|
                 qf.force_encoding('ISO-8859-1').encode('UTF-8')
               end
               params.delete('qf') if params['qf'].all?(&:blank?)
             end
           end
           # Redundant qt param
           params.delete('qt')
           query = Rack::Utils.build_nested_query(params)
           (Europeana::Portal::Application.config.relative_url_root || '') + '/search?' + query
         },
         if: proc { |rack_env|
           (Rack::Utils.parse_query(rack_env['QUERY_STRING']).keys & %w(query rows start qf qt)).present?
         }
  end
end
