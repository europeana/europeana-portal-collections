# frozen_string_literal: true

module Document
  module IIIF
    def iiif?
      return @iiif if instance_variable_defined?(:@iiif)
      @iiif = @record.fetch('services', []).any? do |record_service|
        record_service['about'] == field_value('svcsHasService') &&
          record_service['dctermsConformsTo']&.include?('http://iiif.io/api/image')
      end
    end

    def iiif_manifest
      return @iiif_manifest if instance_variable_defined?(:@iiif_manifest)
      @iiif_manifest = begin
        if iiif?
          manifest = field_value('dctermsIsReferencedBy')
          manifest.present? ? manifest : field_value('svcsHasService') + '/info.json'
        end
      end
    end
  end
end
