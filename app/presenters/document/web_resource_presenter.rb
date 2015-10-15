module Document
  ##
  # Blacklight document presenter for a Europeana web resource
  class WebResourcePresenter < DocumentPresenter
    include ActionView::Helpers::NumberHelper

    def initialize(document, record, controller, configuration = controller.blacklight_config)
      super(document, controller, configuration)
      @record = record
      @record_presenter = RecordPresenter.new(record, controller)
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
          url: download_url,
          text: t('site.object.actions.download')
        }
      }.tap do |item|
        if player.nil?
          item[:is_unknown_type] = url
        else
          item[:"is_#{player}"] = true
        end
      end
    end

    def play_url
      @play_url ||= begin
        @record_presenter.iiif_manifesto || url
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
      Rails.application.config.x.europeana_media_proxy &&
        mime_type.present? &&
        mime_type.match('image/').nil?
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
        format: (play_url.blank? ? '' : play_url.split('.').last),
        language: '',
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

    def playable?
      if url.blank? ||
          (media_type != 'iiif' && mime_type.blank?) ||
          (mime_type == 'video/mpeg') ||
          (media_type == 'text' && mime_type == 'text/plain; charset=utf-8') ||
          (media_type == 'video' && mime_type == 'text/plain; charset=utf-8')
        false
      else
        true
      end
    end

    def downloadable?
      if url.blank? ||
          mime_type.blank? ||
          download_disabled? ||
          media_type == 'iiif' ||
          (media_type == 'text' && mime_type == 'text/plain; charset=utf-8') ||
          (media_type == 'video' && mime_type == 'text/plain; charset=utf-8')
        false
      else
        true
      end
    end

    def download_disabled?
      blacklisted = %w(http://www.europeana.eu/rights/rr-p/ http://www.europeana.eu/rights/rr-r/)
      blacklisted.include?(media_rights)
    end

    def thumbnail
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
