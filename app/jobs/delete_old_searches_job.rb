# frozen_string_literal: true

##
# Deletes from the database searches older than 1 day
class DeleteOldSearchesJob < ApplicationJob
  queue_as :default

  def perform
    total = 0

    Search.where('updated_at < ?', Time.zone.now - 1.day).find_each do |search|
      search.destroy
      total += 1

      if total > 10_000
        # Delete a max of 10000 per job
        self.class.perform_later
        break
      end
    end
  end
end
