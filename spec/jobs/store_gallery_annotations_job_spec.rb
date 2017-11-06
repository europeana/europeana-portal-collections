# frozen_string_literal: true
RSpec.describe StoreGalleryAnnotationsJob, :annotations_api do
  let(:gallery) { Gallery.published.first }

  it 'should be in the "annotations" queue' do
    expect { described_class.perform_later(gallery.slug) }.
      to have_enqueued_job.on_queue('annotations')
  end

  context 'with gallery annotations enabled' do
    before do
      Rails.application.config.x.enable.gallery_annotations = 1
      Rails.application.config.x.europeana[:annotations].api_user_token_gallery = annotations_api_user_token
    end

    it 'should fetch existing annotations' do
      WebMock::Config.instance.query_values_notation = :flat_array
      described_class.perform_now(gallery.slug)

      expected_query = [
        'pageSize=100',
        'profile=standard',
        'qf=creator_name:"Europeana.eu Gallery"',
        'qf=link_relation:isGatheredInto',
        %(qf=link_resource_uri:"https://www.europeana.eu/portal/explore/galleries/#{gallery.slug}"),
        'qf=motivation:linking',
        'query=*:*',
        "wskey=#{annotations_api_key}",
      ].join('&')

      expect(a_request(:get, annotations_api_search_method_url).
        with(query: expected_query)).
        to have_been_made.once

      WebMock::Config.instance.query_values_notation = nil
    end

    it 'should create non-existent annotations' do
      described_class.perform_now(gallery.slug)

      expect(a_request(:post, annotations_api_create_method_url).
        with(query: hash_including(wskey: annotations_api_key, userToken: annotations_api_user_token))).
        to have_been_made.times(2)
      expect(a_request(:post, annotations_api_create_method_url).
        with(
          query: hash_including(wskey: annotations_api_key, userToken: annotations_api_user_token),
          body: gallery.images.first.annotation.send(:body_params).to_json
        )).
        to have_been_made.once
      expect(a_request(:post, annotations_api_create_method_url).
        with(
          query: hash_including(wskey: annotations_api_key, userToken: annotations_api_user_token),
          body: gallery.images.last.annotation.send(:body_params).to_json
        )).
        to have_been_made.once
    end

    it 'should delete redundant annotations' do
      described_class.perform_now(gallery.slug)

      expect(a_request(:delete, annotations_api_delete_method_url).
        with(query: hash_including(wskey: annotations_api_key, userToken: annotations_api_user_token))).
        to have_been_made.times(2)
      expect(a_request(:delete, "#{annotations_api_url}/annotations/abc/123").
        with(query: hash_including(wskey: annotations_api_key, userToken: annotations_api_user_token))).
        to have_been_made.once
      expect(a_request(:delete, "#{annotations_api_url}/annotations/def/456").
        with(query: hash_including(wskey: annotations_api_key, userToken: annotations_api_user_token))).
        to have_been_made.once
    end
  end

  context 'with gallery annotations not enabled' do
    before do
      Rails.application.config.x.enable.gallery_annotations = nil
    end

    it 'fails' do
      expect { described_class.perform_now(gallery.slug) }.
        to raise_exception('Gallery annotations functionality is not configured.')
    end
  end

  context 'without user token configured' do
    before do
      Rails.application.config.x.europeana[:annotations].api_user_token_gallery = nil
    end

    it 'fails' do
      expect { described_class.perform_now(gallery.slug) }.
        to raise_exception('Gallery annotations functionality is not configured.')
    end
  end
end
