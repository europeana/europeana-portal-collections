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

  def simple_rights_label_data
    return nil unless media_rights.present?
    # global.facet.reusability.permission      Only with permission
    # global.facet.reusability.open            Yes with attribution
    # global.facet.reusability.restricted      Yes with restrictions

    case media_rights
    when %r{http://creativecommons.org/publicdomain/zero}
      {
        license_human: t('global.facet.reusability.open'),
        license_name: t('global.facet.reusability.advanced-cc0'),
        license_url: media_rights,
        license_CC0: true
      }
    when %r{http://creativecommons.org/licenses/by/}
      {
        license_human: t('global.facet.reusability.open'),
        license_name: t('global.facet.reusability.advanced-cc-by'),
        license_url: media_rights,
        license_CC_BY: true
      }
    when %r{http://creativecommons.org/licenses/by-nc/}
      {
        license_human: t('global.facet.reusability.open'),
        license_name: t('global.facet.reusability.advanced-cc-by-nc'),
        license_url: media_rights,
        license_CC_BY_NC: true
      }
    when %r{http://creativecommons.org/licenses/by-nc-nd}
      {
        license_human: t('global.facet.reusability.restricted'),
        license_name: t('global.facet.reusability.advanced-cc-by-nc-nd'),
        license_url: media_rights,
        license_CC_BY_NC_ND: true
      }
    when %r{http://creativecommons.org/licenses/by-nc-sa}
      {
        license_human: t('global.facet.reusability.restricted'),
        license_name: t('global.facet.reusability.advanced-cc-by-nc-sa'),
        license_url: media_rights,
        license_CC_BY_NC_SA: true
      }
    when %r{http://creativecommons.org/licenses/by-nd}
      {
        license_human: t('global.facet.reusability.restricted'),
        license_name: t('global.facet.reusability.advanced-cc-by-nd'),
        license_url: media_rights,
        license_CC_BY_ND: true
      }
    when %r{http://creativecommons.org/licenses/by-sa}
      {
        license_human: t('global.facet.reusability.open'),
        license_name: t('global.facet.reusability.advanced-cc-by-sa'),
        license_url: media_rights,
        license_CC_BY_SA: true
      }
    when %r{http://www.europeana.eu/rights/out-of-copyright-non-commercial}
      {
        license_human: t('global.facet.reusability.restricted'),
        license_name: t('global.facet.reusability.advanced-out-of-copyright-non-commercial'),
        license_url: media_rights,
        license_OOC: true
      }
    when %r{http://www.europeana.eu/rights/rr-f}
      {
        license_human: t('global.facet.reusability.permission'),
        license_name: t('global.facet.reusability.advanced-rrfa'),
        license_url: media_rights,
        license_RR_free: true
      }
    when %r{http://www.europeana.eu/rights/rr-p}
      {
        license_human: t('global.facet.reusability.permission'),
        license_name: t('global.facet.reusability.advanced-rrpa'),
        license_url: media_rights,
        license_RR_paid: true
      }
    when %r{http://www.europeana.eu/rights/rr-r/}
      {
        license_human: t('global.facet.reusability.permission'),
        license_name: t('global.facet.reusability.advanced-rrra'),
        license_url: media_rights,
        license_RR_restricted: true
      }
    when %r{http://creativecommons.org/publicdomain/mark}
      {
        license_public: true,
        license_name: t('global.facet.reusability.advanced-pdm'),
        license_url: media_rights,
        license_human: t('global.facet.reusability.open')
      }
    when %r{http://www.europeana.eu/rights/unknown}
      {
        license_unknown: true,
        license_name: t('global.facet.reusability.advanced-ucs'),
        license_url: media_rights,
        license_human: t('global.facet.reusability.permission')
      }
    when %r{http://www.europeana.eu/rights/test-orphan}
      {
        license_orphan: true,
        license_name: t('global.facet.reusability.advanced-orphan-work'),
        license_url: media_rights,
        license_human: t('global.facet.reusability.permission')
      }
    else
      {
        license_public: false,
        license_name: 'unmatched rights: ' + media_rights,
        license_url: media_rights
      }
    end
  end
end
