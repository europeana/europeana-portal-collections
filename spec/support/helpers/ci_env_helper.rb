# frozen_string_literal: true

##
# Helpers for CI environments
module CiEnvHelper
  ##
  # Try to determine if tests are running in a CI env
  def running_in_ci_env?
    ENV['CI'] || ENV['JENKINS_URL'] ? true : false
  end
end
