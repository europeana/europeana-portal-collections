# frozen_string_literal: true

$:.push(File.expand_path('commands', __dir__))

require 'rails/generators'
require 'thor'
require 'europeana/portal/docker/docker_command'

module Europeana
  module Portal
    class CLI < Thor
      namespace 'portal'

      register(Europeana::Portal::DockerCommand, 'dockerize', 'dockerize [RAILS_ENV]', 'Configure for Docker')
    end
  end
end
