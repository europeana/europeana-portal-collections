##
# Base class for Blacklight document presenters
class DocumentPresenter < Europeana::Blacklight::DocumentPresenter
  delegate :t, to: I18n

  ##
  # Override to prevent HTML escaping, handled by {Mustache}
  #
  # @see Blacklight::DocumentPresenter#render_values
  def render_values(values, field_config = nil)
    options = {}
    options = field_config.separator_options if field_config && field_config.separator_options

    values.to_sentence(options)
  end

  def rights_label_expiry(rights)
    if rights.id == :out_of_copyright_non_commercial
      end_path = URI(media_rights).path.split('/').last
      unless end_path == 'out-of-copyright-non-commercial'
        expiry = t('global.facet.reusability.expiry', date: end_path)
      end
    end
  end

  def simple_rights_label_data
    return nil unless media_rights.present?
    # global.facet.reusability.permission      Only with permission
    # global.facet.reusability.open            Yes with attribution
    # global.facet.reusability.restricted      Yes with restrictions

    begin
      rights = EDM::Rights.normalise(media_rights)
      license_flag_key = rights.template_license.present? ? rights.template_license : rights.id.to_s.upcase.tr('_', '-')

      {
        license_human: t(rights.reusability, scope: 'global.facet.reusability'),
        license_name: rights.label,
        license_url: media_rights,
        :"license_#{license_flag_key}" => true,
        expiry: rights_label_expiry(rights)
      }
    rescue EDM::Rights::UnknownRights
      {
        license_public: false,
        license_name: 'unmatched rights: ' + media_rights,
        license_url: media_rights
      }
    end
  end
end
