# frozen_string_literal: true

module I18nHelper
  def language_options_for_select
    localised = I18n.available_locales.map do |locale|
      [t(locale, scope: 'global.languages', locale: locale), locale.to_s]
    end
    localised.sort_by!(&:first)
    options_for_select(localised, I18n.locale.to_s)
  end

  def date_eras_gregorian(date)
    return nil unless date.is_a?(String)

    # Try various format handlers.
    %i(digits_only plus_minus_prefix second_century_ce abnormal_ce abnormal_bce).each do |meth|
      gregorian = send(:"date_eras_gregorian_#{meth}", date)
      return gregorian unless gregorian.nil?
    end

    nil
  end

  private

  # Match on digits+ only, strip starting '0's and if date' length 1-3 then build "date' + CE"
  def date_eras_gregorian_digits_only(date)
    m = date.match(/^\d+$/)
    return nil if m.nil?

    return nil if strip_leading_zeroes(m[0]).length > 3

    suffix_gregorian_era_date(m[0], '+')
  end

  # Match on '+' or '-' followed by date where date starts with digit followed by one or more digits or hyphens
  # If the matched date contains hyphens, then it must have the format 'yyyy-dd-dd'
  def date_eras_gregorian_plus_minus_prefix(date)
    m = date.match(/^\s*(\+|\-)\s*(\d[\d\-]*)\s*$/i)
    return nil if m.nil?

    prefix = m[1]
    year = m[2]

    unless year.include?('-') && !year.match(/^\d{1,4}\-\d{1,2}\-\d{1,2}$/)
      suffix_gregorian_era_date(year, prefix)
    end
  end

  # 0mit CE from years > 999', e.g. 'c. 1066', 'c.1066', '1066 AD' or 'c. 1066 AD' => '1066'
  def date_eras_gregorian_second_century_ce(date)
    m = date.match(/^\s*(?:c\.)?\s*(\d{4})\s*(?:AD|CE)?\s*$/i)
    m.nil? ? nil : m[1]
  end

  # Match abnormal CE dates.
  # 'c. AD 46', 'a. de C. 46', 'c. 46', 'c.46', 'c.46 AD' or 'circa 46' => '46 CE'
  def date_eras_gregorian_abnormal_ce(date)
    ['c. AD', 'a. de C.', 'c.', 'circa'].each do |abbrev|
      m = date.match(/^\s*#{abbrev}\s*(\d[\d\-]*)\s*(?:AD)?\s*$/i)
      return suffix_gregorian_era_date(m[1], '+') unless m.nil?
    end

    nil
  end

  # Match abnormal BCE dates.
  # 'About 470 BC', 'About 470 BCE', 'c.470 BCE' or 'circa 470 BCE' => '470 BCE'
  def date_eras_gregorian_abnormal_bce(date)
    %w{About c. circa}.each do |abbrev|
      m = date.match(/^\s*#{abbrev}\s*(\d[\d\-]*)\s*(?:BCE?)?\s*$/i)
      return suffix_gregorian_era_date(m[1], '-') unless m.nil?
    end

    nil
  end

  def suffix_gregorian_era_date(year, prefix)
    year = strip_leading_zeroes(year)
    key = prefix == '+' ? 'current' : 'before'
    t(key, scope: 'global.date.eras.gregorian', date: year)
  end

  def strip_leading_zeroes(s)
    s.strip.sub(/^0+/, '')
  end
end
