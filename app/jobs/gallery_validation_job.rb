# frozen_string_literal: true

##
# Validate that a gallery has only properly displaying images
# Should an issue be discovered an email is sent to notify editors.
class GalleryValidationJob < ApplicationJob
  queue_as :default

  def perform(gallery_id)
    fail 'No gallery validation email set.' unless Rails.application.config.x.gallery_validation_mail_to

    @gallery = Gallery.find(gallery_id)
    @validation_errors = {}
    @gallery.images.each do |gallery_image|
      validate_gallery_image(gallery_image)
    end

    notify if @validation_errors.present?
  end

  private

  def validate_gallery_image(gallery_image)
    errors = []
    europeana_id = gallery_image.europeana_record_id
    stored_image_url = gallery_image.url
    api_document = api_search_response.detect { |record| record['id'] == europeana_id }
    if api_document
      unless api_document['edmIsShownBy']&.first == stored_image_url
        errors << 'edm:isShownBy has changed'
      end
      unless retrievable_image?(stored_image_url)
        errors << "can not retrieve #{stored_image_url}"
      end
    else
      errors << 'record not found on API; it may have been deleted'
    end
    @validation_errors[europeana_id] = errors if errors.present?
  end

  def api_search_response
    @api_search_response ||= begin
      api_query = Europeana::Record.search_api_query_for_record_ids(@gallery.images.map(&:europeana_record_id))
      Europeana::API.record.search(query: api_query, profile: 'rich', rows: 100)['items'] || []
    end
  end

  def retrievable_image?(is_shown_by)
    response = download_response(is_shown_by)
    return false unless response
    content_type = response.headers[:content_type]
    return false unless content_type&.start_with?('image')
    true
  end

  def download_response(url)
    RestClient.get(url)
  rescue ::RestClient::ExceptionWithResponse
    false
  end

  def notify
    GalleryValidationMailer.post(gallery: @gallery, validation_errors: @validation_errors).deliver_later
  end
end
