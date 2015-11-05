##
# Deletes from the database searches older than 1 week
class DeleteOldSearchesJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Search.destroy_all(['updated_at < ?', Time.now - 1.week])
  end
end
