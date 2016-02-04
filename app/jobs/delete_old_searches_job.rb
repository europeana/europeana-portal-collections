##
# Deletes from the database searches older than 1 week
class DeleteOldSearchesJob < ActiveJob::Base
  queue_as :default

  def perform
    Search.where('updated_at < ?', Time.zone.now - 1.week).find_each do |search|
      search.destroy
    end
  end
end
