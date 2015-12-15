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

    def media_item
      {
        media_type: media_type,
        rights: simple_rights_label_data,
        downloadable: downloadable?,
        playable: playable?,
        thumbnail: thumbnail,
        play_url: play_url,
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

    def url
      @url ||= render_document_show_field_value('about')
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

    # Media type function normalises mime types
    def media_type
      @media_type ||= begin
        if @record_presenter.iiif_manifesto
          'iiif'
        else
          case (mime_type || '').downcase
          when /^audio\//
            'audio'
          when /^image\//
            'image'
          when /^video\//
            'video'
          when /^text\//, /\/pdf$/
            'text'
          else
            @record_presenter.render_document_show_field_value('type')
          end
        end
      end
    end

    def edm_media_type
      @edm_media_type ||= begin
        record_type = @record_presenter.render_document_show_field_value('type')
        if record_type == '3D' || media_type == 'iiif'
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
      width   = render_document_show_field_value('ebucoreWidth')
      height  = render_document_show_field_value('ebucoreHeight')

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
        runtime_unit: t('site.object.meta-label.runtime-unit-seconds')
      }
    end

    def is_avi?
      avi_fmts = []
      avi_fmts << 'video/avi'
      avi_fmts << 'video/msvideo'
      avi_fmts << 'video/x-msvideo'
      avi_fmts << 'image/avi'
      avi_fmts << 'video/xmpg2'
      avi_fmts << 'application/x-troff-msvideo'
      avi_fmts << 'audio/aiff'
      avi_fmts << 'audio/avi'
      avi_fmts.include? mime_type
    end

    def playable?
      if url.blank? ||
          (media_type != 'iiif' && mime_type.blank?) ||
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

    def displayable?
      return false if for_edm_object? && @record_presenter.edm_object_thumbnails_edm_is_shown_by?

      (@record_presenter.edm_object.present? && for_edm_object?) ||
        (@record_presenter.edm_object.blank? && for_edm_is_shown_by?) ||
        (@record_presenter.edm_object_thumbnails_edm_is_shown_by? && for_edm_is_shown_by?) ||
        (@record_presenter.has_views.include?(url) && mime_type.present?) ||
        (media_type == 'iiif')
    end

    def download_disabled?
      # blacklisted1 = %w(http://www.europeana.eu/rights/rr-p/ http://www.europeana.eu/rights/rr-r/ http://www.europeana.eu/rights/rr-f/)
      # blacklisted2 = %w(http://www.europeana.eu/rights/test-orphan http://www.europeana.eu/rights/unknown)
      # blacklisted1.include?(media_rights) || blacklisted2.include?(media_rights)
      false
    end

    def thumbnail
      if edm_object_thumbnail?
       @record_presenter.media_web_resource_presenters.find { |p| p.url == @record_presenter.edm_object }.api_thumbnail
      else
        api_thumbnail
      end
    end

    def edm_object_thumbnail?
      for_edm_is_shown_by? &&
        @record_presenter.edm_object_thumbnails_edm_is_shown_by?
    end

    def api_thumbnail
      Europeana::API.url + '/thumbnail-by-url.json?size=w400&uri=' + CGI.escape(url) + '&type=' + edm_media_type
    end

    def player
      @player ||= begin
        case media_type
        when 'image'
          :image
        when 'audio', 'sound'
          :audio
        when 'iiif'
          :iiif
        when 'pdf'
          :pdf
        when 'text'
          mime_type == 'application/pdf' ? :pdf : :text
        when 'video'
          :video
        end
      end
    end
  end
end
