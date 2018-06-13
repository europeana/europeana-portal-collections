# frozen_string_literal: true

module ApiResponseFixtures
  ##
  # Renders ERB fixtures with local variables
  class Fixture
    def self.empty_binding
      binding
    end

    def self.render(template_content, **locals)
      b = empty_binding
      locals.each { |k, v| b.local_variable_set(k, v) }
      b.local_variable_set(:local_assigns, locals)
      ERB.new(template_content).result(b)
    end
  end

  ##
  # Renders one API response fixture, mimicking Rails fixture accessor naming
  #
  # API response fixtures are .json.erb files in spec/fixtures/api_response/
  #
  # @param name [Symbol] API response fixture name
  # @param locals [Hash] Local variables to pass to the ERB template
  # @return [String] JSON string for an API response to use in a stubbed request
  def api_responses(name, **locals)
    format = locals.delete(:format) || 'json'
    path = File.expand_path("../../../fixtures/api_response/#{name}.#{format}.erb", __FILE__)
    Fixture.render(File.read(path), **locals)
  end
end
