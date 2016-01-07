##
# Base class for Blacklight document presenters
class DocumentPresenter < Europeana::Blacklight::DocumentPresenter
  delegate :t, to: I18n

  def render_field_value(value = nil, field_config = nil)
    safe_values = Array(value)

    if field_config && field_config.limit.is_a?(Integer)
      max_i = field_config.limit - 1
      safe_values = safe_values[0..max_i]
    end

    safe_values.map! { |x| x.respond_to?(:force_encoding) ? x.force_encoding('UTF-8') : x }

    if field_config && field_config.itemprop
      safe_values.map! { |x| content_tag :span, x, itemprop: field_config.itemprop }
    end

    # Do not use {safe_join} to escape HTML because that is done by {Mustache}
    safe_values.join((field_config.separator if field_config) || field_value_separator)
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
        license_CC0: true
      }
    when %r{http://creativecommons.org/licenses/by/}
      {
        license_human: t('global.facet.reusability.open'),
        license_name: t('global.facet.reusability.advanced-cc-by'),
        license_CC_BY: true
      }
    when %r{http://creativecommons.org/licenses/by-nc/}
      {
        license_human: t('global.facet.reusability.open'),
        license_name: t('global.facet.reusability.advanced-cc-by-nc'),
        license_CC_BY_NC: true
      }
    when %r{http://creativecommons.org/licenses/by-nc-nd}
      {
        license_human: t('global.facet.reusability.restricted'),
        license_name: t('global.facet.reusability.advanced-cc-by-nc-nd'),
        license_CC_BY_NC_ND: true
      }
    when %r{http://creativecommons.org/licenses/by-nc-sa}
      {
        license_human: t('global.facet.reusability.restricted'),
        license_name: t('global.facet.reusability.advanced-cc-by-nc-sa'),
        license_CC_BY_NC_SA: true
      }
    when %r{http://creativecommons.org/licenses/by-nd}
      {
        license_human: t('global.facet.reusability.restricted'),
        license_name: t('global.facet.reusability.advanced-cc-by-nd'),
        license_CC_BY_ND: true
      }
    when %r{http://creativecommons.org/licenses/by-sa}
      {
        license_human: t('global.facet.reusability.open'),
        license_name: t('global.facet.reusability.advanced-cc-by-sa'),
        license_CC_BY_SA: true
      }
    when %r{http://www.europeana.eu/rights/out-of-copyright-non-commercial}
      {
        license_human: t('global.facet.reusability.restricted'),
        license_name: t('global.facet.reusability.advanced-out-of-copyright-non-commercial'),
        license_OOC: true
      }
    when %r{http://www.europeana.eu/rights/rr-f}
      {
        license_human: t('global.facet.reusability.permission'),
        license_name: t('global.facet.reusability.advanced-rrfa'),
        license_RR_free: true
      }
    when %r{http://www.europeana.eu/rights/rr-p}
      {
        license_human: t('global.facet.reusability.permission'),
        license_name: t('global.facet.reusability.advanced-rrpa'),
        license_RR_paid: true
      }
    when %r{http://www.europeana.eu/rights/rr-r/}
      {
        license_human: t('global.facet.reusability.permission'),
        license_name: t('global.facet.reusability.advanced-rrra'),
        license_RR_restricted: true
      }
    when %r{http://creativecommons.org/publicdomain/mark}
      {
        license_public: true,
        license_name: t('global.facet.reusability.advanced-pdm'),
        license_human: t('global.facet.reusability.open')
      }
    when %r{http://www.europeana.eu/rights/unknown}
      {
        license_unknown: true,
        license_name: t('global.facet.reusability.advanced-ucs'),
        license_human: t('global.facet.reusability.permission')
      }
    when %r{http://www.europeana.eu/rights/test-orphan}
      {
        license_orphan: true,
        license_name: t('global.facet.reusability.advanced-orphan-work'),
        license_human: t('global.facet.reusability.permission')
      }
    else
      {
        license_public: false,
        license_name: 'unmatched rights: ' + media_rights
      }
    end
  end
end
