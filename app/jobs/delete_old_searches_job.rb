##
# Deletes from the database searches older than 1 week
class DeleteOldSearchesJob < ActiveJob::Base
  queue_as :default

  def perform
    Search.destroy_all(['updated_at < ?', Time.zone.now - 1.week])
  end
end
