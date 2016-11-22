# frozen_string_literal: true
module Document
  module Metadata
    module Rights
      def rights_label_expiry(rights)
        if rights.id == :out_of_copyright_non_commercial
          end_path = URI(media_rights).path.split('/').last
          if end_path == 'out-of-copyright-non-commercial'
            nil
          else
            t('global.facet.reusability.expiry', date: end_path)
          end
        elsif !media_licenses_odrlInheritFrom.blank?
          end_path = URI(media_licenses_about).path.split('/').last
          if end_path == 'out-of-copyright-non-commercial'
            nil
          else
            t('global.facet.reusability.expiry', date: end_path)
          end
        end
      end

      def simple_rights_label_data
        return nil unless media_rights.present?
        # global.facet.reusability.permission      Only with permission
        # global.facet.reusability.open            Yes with attribution
        # global.facet.reusability.restricted      Yes with restrictions
        rights = EDM::Rights.normalise(media_rights)
        unless media_licenses_odrlInheritFrom.blank?
          rights = EDM::Rights.normalise(media_licenses_odrlInheritFrom)
        end
        simple_rights(rights)
      end

      def simple_rights(rights)
        if rights.nil?
          {
            license_public: false,
            license_name: 'unmatched rights: ' + media_rights,
            license_url: media_rights
          }
        else
          license_flag_key = rights.template_license.present? ? rights.template_license : rights.id.to_s.upcase
          {
            license_human: t(rights.reusability, scope: 'global.facet.reusability'),
            license_name: rights.label,
            license_url: media_rights,
            :"license_#{license_flag_key}" => true,
            expiry: rights_label_expiry(rights)
          }
        end
      end
    end
  end
end
