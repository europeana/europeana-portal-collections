##
# Base class job background jobs
class ApplicationJob < ActiveJob::Base
  include ActiveSupport::Benchmarkable
end
