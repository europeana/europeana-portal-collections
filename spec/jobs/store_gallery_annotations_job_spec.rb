# frozen_string_literal: true
RSpec.describe StoreGalleryAnnotationsJob do
  let(:gallery) { Gallery.first }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it 'should be in the "annotations" queue' do
    expect { StoreGalleryAnnotationsJob.perform_later(gallery.id) }.
      to have_enqueued_job.on_queue('annotations')
  end

  it 'should fetch existing annotations'
  it 'should restrict annotations scope by generator name'
  it 'should further filter annotations by '

  it 'should queue jobs to create non-existent annotations'

  it 'should queue jobs to delete redundant annotations'
end
