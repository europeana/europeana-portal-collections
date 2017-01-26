##
# Job to harvest from the Europeana Record API the metadata for a single
# `Europeana::Record`
class HarvestEuropeanaRecordJob < ActiveJob::Base
  queue_as :harvest

  def perform(europeana_record_id)
    record = Europeana::Record.find(europeana_record_id)
    api_response = Europeana::API.record.fetch(id: record.europeana_id)
    record.update_attributes(metadata: api_response['object'])
  end
end
