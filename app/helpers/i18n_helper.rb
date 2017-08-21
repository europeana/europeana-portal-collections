# frozen_string_literal: true

module I18nHelper
  def language_map
    {
      bg: 'bulgarian',
      ca: 'catalan',
      da: 'danish',
      de: 'german',
      el: 'greek',
      en: 'english',
      es: 'spanish',
      et: 'estonian',
      fi: 'finnish',
      fr: 'french',
      hr: 'croatian',
      hu: 'hungarian',
      it: 'italian',
      lt: 'lithuanian',
      lv: 'latvian',
      mt: 'maltese',
      no: 'norwegian',
      nl: 'dutch',
      pl: 'polish',
      pt: 'portuguese',
      ro: 'romanian',
      ru: 'russian',
      sv: 'swedish'
    }
  end

  def language_options_for_select
    localised = language_map.map { |k, v| [t("global.language-#{v}", locale: k), k.to_s] }
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

  # Return the most accurate date from an array of dates using scoring algorithm below
  def date_most_accurate(dates)
    return nil unless dates.present?
    if dates.is_a?(String)
      return date_eras_gregorian(dates) || dates.strip
    end
    date_eras = dates.map { |date| date_eras_gregorian(date) || date }.compact
    return date_eras[0] if date_eras.length == 1
    date_scores = date_eras.each_with_object({}) { |date, memo| memo[date] = date_score(date) }
    date_scores.key(date_scores.values.max)
  end

  # Give the date a score based on the possible date formats:
  # '1957' => 1 point
  # '1957-10' => 2 points
  # '1957-10-11' => 3 points
  # 'CE' or 'BCE' => 1 point extra
  # otherwise => 0
  #
  # Valid date combinations of year=y, month=m and day=d:
  # y, yy, yyy, yyyy, y-m, yy-m, yyy-m, yyyy-m, y-mm, yy-mm, yyy-mm, yyyy-mm
  # y-m-d, yy-m-d, yyy-m-d, yyyy-m-d, y-mm-d, yy-mm-d, yyy-mm-d, yyyy-mm-d
  # y-m-dd, yy-m-dd, yyy-m-dd, yyyy-m-dd, y-mm-dd, yy-mm-dd, yyy-mm-dd, yyyy-mm-dd
  #
  def date_score(date)
    return 0 unless date.present?

    m = date.strip.match(/^(\d{1,4})(-\d{1,2})?(-\d{1,2})?( B?CE)?$/)

    m.nil? ? 0 : m.to_a.compact.length - 1
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
