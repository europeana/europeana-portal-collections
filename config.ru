# This file is used by Rack-based servers to start the application.

require 'rails_with_relative_url_root'

require ::File.expand_path('../config/environment', __FILE__)

run RailsWithRelativeUrlRoot.application
