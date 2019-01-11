# frozen_string_literal: true

module Rack
  ##
  # Rack middleware to enforce requests at a given HTTP host
  #
  # HTTP host to enforce is set in the env var `HTTP_HOST`.
  #
  # Enforcement is by HTTP redirect 301.
  class EnforceHttpHost
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      return redirect(url_on_enforced_host(request)) if enforce_host_for?(request)

      @app.call(env)
    end

    def enforce_host_for?(request)
      enforced_host.present? &&
        !skip_host_enforcement_on?(request) &&
        !request_on_enforced_host?(request)
    end

    def skip_host_enforcement_on?(request)
      request.path == (ENV['RAILS_RELATIVE_URL_ROOT'] || '') + '/status'
    end

    def request_on_enforced_host?(request)
      request.host_with_port == enforced_host
    end

    def url_on_enforced_host(request)
      "#{request.scheme}://#{enforced_host}#{request.fullpath}"
    end

    def enforced_host
      ENV['HTTP_HOST']
    end

    def redirect(location)
      [
        301,
        { 'Location' => location, 'Content-Type' => 'text/plain' },
        [Rack::Utils::HTTP_STATUS_CODES[301]]
      ]
    end
  end
end
