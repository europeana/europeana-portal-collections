module Document
  ##
  # Blacklight document presenter for a Europeana web resource
  class WebResourcePresenter < DocumentPresenter
    include ActionView::Helpers::NumberHelper

    def initialize(document, controller, configuration = controller.blacklight_config, record = nil, record_presenter = nil)
      super(document, controller, configuration)
      @record = record
      @record_presenter = record_presenter || (record.nil? ? nil : RecordPresenter.new(record, controller))
    end

    ##
    # This is the data required by the view template
    def media_item
      {
        media_type: media_type,
        rights: simple_rights_label_data,
        downloadable: downloadable?,
        playable: playable?,
        thumbnail: thumbnail,
        play_url: play_url,
        play_html: play_html,
        technical_metadata: technical_metadata,
        download: {
          url: downloadable? ? download_url : false,
          text: t('site.object.actions.download')
        }
      }.tap do |item|
        if player.nil?
          item[:is_unknown_type] = url
        else
          item[:"is_#{player}"] = true
        end
        item[:external_media] = download_url == @record_presenter.edm_object ? @record_presenter.is_shown_by_or_at : download_url
      end
    end

    def play_url
      @play_url ||= begin
        @record_presenter.iiif_manifesto || download_url
      end
    end

    def play_html
      @play_html ||= begin
        return nil unless media_type == 'oembed'
        @controller.oembed_html[url][:html]
      end
    end

    def url
      @url ||= begin
        url = render_document_show_field_value('about')
        @controller.url_conversions[url] || url
      end
    end

    def media_rights
      @media_rights ||= begin
        rights = render_document_show_field_value('webResourceEdmRights')
        rights.blank? ? @record_presenter.media_rights : rights
      end
    end

    def mime_type
      @mime_type ||= render_document_show_field_value('ebucoreHasMimeType')
    end

    def record_type
      @record_type ||= @record_presenter.render_document_show_field_value('type')
    end

    # Media type function normalises mime types
    def media_type
      @media_type ||= (media_type_special_case || media_type_from_mime_type || media_type_from_record_type)
    end

    def media_type_special_case
      case
      when @record_presenter.iiif_manifesto
        'iiif'
      when @controller.oembed_html.key?(url)
        'oembed'
      end
    end

    def media_type_from_mime_type
      case (mime_type || '').downcase
      when /^audio\//
        'audio'
      when /^image\//
        'image'
      when /^video\//
        'video'
      when /^text\//, /\/pdf$/
        'text'
      end
    end

    def media_type_from_record_type
      case record_type
      when '3D'
        '3D'
      when 'SOUND'
        'audio'
      else
        record_type.downcase
      end
    end

    def edm_media_type
      @edm_media_type ||= begin
        if record_type == '3D' || %w(iiif oembed).include?(media_type)
          record_type
        elsif media_type == 'audio'
          'SOUND'
        else
          media_type.upcase
        end
      end
    end

    def use_media_proxy?
      Rails.application.config.x.europeana_media_proxy && mime_type.present?
    end

    def download_url
      @download_url ||= begin
        if use_media_proxy?
          Rails.application.config.x.europeana_media_proxy + @record.fetch('about', '/') + '?view=' + CGI.escape(url)
        else
          url
        end
      end
    end

    def technical_metadata
      width = render_document_show_field_value('ebucoreWidth')
      height = render_document_show_field_value('ebucoreHeight')

      file_size = number_to_human_size(render_document_show_field_value('ebucoreFileByteSize')) || ''
      {
        mime_type: mime_type,
        format: render_document_show_field_value('ebucoreHasMimeType'),
        file_size: file_size.split(' ').first,
        file_unit: file_size.split(' ').last,
        codec: render_document_show_field_value('edmCodecName'),
        width: width,
        height: height,
        width_or_height: !(width.blank? && height.blank?),
        size_unit: 'pixels',
        runtime: render_document_show_field_value('ebucoreDuration'),
        runtime_unit: t('site.object.meta-label.runtime-unit-seconds'),
        attribution_plain: render_document_show_field_value('textAttributionSnippet'),
        attribution_html: render_document_show_field_value('htmlAttributionSnippet')
      }
    end

    def is_avi?
      %w(video/avi video/msvideo video/x-msvideo image/avi video/xmpg2
         application/x-troff-msvideo audio/aiff audio/avi).include?(mime_type)
    end

    def displayable?
      return false if for_edm_object? && @record_presenter.edm_object_thumbnails_edm_is_shown_by?

      (@record_presenter.edm_object.present? && for_edm_object?) ||
        (@record_presenter.edm_object.blank? && for_edm_is_shown_by?) ||
        (@record_presenter.edm_object_thumbnails_edm_is_shown_by? && for_edm_is_shown_by?) ||
        (@record_presenter.has_views.include?(url) && mime_type.present?) ||
        playable_without_mime_type?
    end

    def playable?
      if url.blank? ||
          (mime_type.blank? && !playable_without_mime_type?) ||
          (mime_type == 'video/mpeg') ||
          (media_type == 'text' && mime_type == 'text/plain; charset=utf-8') ||
          (media_type == 'video' && mime_type == 'text/plain; charset=utf-8') ||
          (media_type == 'image' && render_document_show_field_value('ebucoreWidth').to_i < 400) ||
          is_avi?
        false
      else
        true
      end
    end

    def playable_without_mime_type?
      %w(iiif oembed).include?(media_type)
    end

    def downloadable?
      if url.blank? ||
        download_disabled? ||
        media_type == 'iiif' ||
        (media_type == 'text' && mime_type == 'text/plain; charset=utf-8') ||
        (media_type == 'video' && mime_type == 'text/plain; charset=utf-8')
        false
      else
        @record_presenter.has_views.include?(url) || for_edm_is_shown_by?
      end
    end

    def for_edm_object?
      @record_presenter.edm_object == url
    end

    def for_edm_is_shown_by?
      url == @record_presenter.edm_is_shown_by
    end

    def download_disabled?
      # blacklisted1 = %w(http://www.europeana.eu/rights/rr-p/ http://www.europeana.eu/rights/rr-r/ http://www.europeana.eu/rights/rr-f/)
      # blacklisted2 = %w(http://www.europeana.eu/rights/test-orphan http://www.europeana.eu/rights/unknown)
      # blacklisted1.include?(media_rights) || blacklisted2.include?(media_rights)
      false
    end

    def thumbnail
      siblings = @record_presenter.displayable_media_web_resource_presenters
      use_small = (siblings.size > 1) && (siblings.first != self)
      if edm_object_thumbnail?
        @record_presenter.media_web_resource_presenters.detect { |p| p.url == @record_presenter.edm_object }.api_thumbnail(use_small)
      else
        api_thumbnail(use_small)
      end
    end

    def edm_object_thumbnail?
      for_edm_is_shown_by? &&
        @record_presenter.edm_object_thumbnails_edm_is_shown_by?
    end

    def api_thumbnail(use_small)
      width = use_small ? '200' : '400'
      Europeana::API.url + '/thumbnail-by-url.json?size=w' + width + '&uri=' + CGI.escape(url) + '&type=' + edm_media_type
    end

    def player
      @player ||= begin
        case media_type
        when 'text'
          (mime_type =~ /\/pdf$/) ? :pdf : :text
        else
          media_type.to_sym
        end
      end
    end
  end
end
