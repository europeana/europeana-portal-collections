class DebugController < ApplicationController
  ##
  # Triggers an exception for testing error reporting environments
  def exception
    fail StandardError, 'Erroring at your request'
  end
end
