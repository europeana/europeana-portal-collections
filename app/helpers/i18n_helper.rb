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
    return date unless date.is_a?(String)

    # Match on digits+ only, strip starting '0's and if date' length 1-3 then build "date' + CE"
    m = date.match(/^\d+$/)
    return build_date(m[0], '+') if m && strip_leading_zeroes(m[0]).length < 4

    # Match on '+' or '-' followed by date where date starts with digit followed by one or more digits or hyphens
    # If the matched date contains hyphens, then it must have the format 'yyyy-dd-dd'
    m = date.match(/^\s*(\+|\-)\s*(\d[\d\-]*)\s*$/i)
    if m
      year = m[2]
      return build_date(year, m[1]) unless year.include?('-') && !year.match(/^\d{1,4}\-\d{1,2}\-\d{1,2}$/)
    end

    # 0mit CE from years > 999', e.g. 'c. 1066', 'c.1066', '1066 AD' or 'c. 1066 AD' => '1066'
    m = date.match(/^\s*(?:c\.)?\s*(\d{4})\s*(?:AD|CE)?\s*$/i)
    return m[1] if m

    # Match abnormal CE dates.
    # 'c. AD 46', 'a. de C. 46', 'c. 46', 'c.46', 'c.46 AD' or 'circa 46' => '46 CE'
    ['c. AD', 'a. de C.', 'c.', 'circa'].each do |abbrev|
      m = date.match(/^\s*#{abbrev}\s*(\d[\d\-]*)\s*(?:AD)?\s*$/i)
      return build_date(m[1], '+') if m
    end

    # Match abnormal BCE dates.
    # 'About 470 BC', 'About 470 BCE', 'c.470 BCE' or 'circa 470 BCE' => '470 BCE'
    %w{About c. circa}.each do |abbrev|
      m = date.match(/^\s*#{abbrev}\s*(\d[\d\-]*)\s*(?:BCE?)?\s*$/i)
      return build_date(m[1], '-') if m
    end

    # Otherwise just strip.
    date.strip
  end

  private

  def build_date(year, prefix)
    year = strip_leading_zeroes(year)
    key = prefix == '+' ? 'current' : 'before'
    t(key, scope: 'global.date.eras.gregorian', years: year)
  end

  def strip_leading_zeroes(s)
    s.strip.sub(/^0+/, '')
  end
end
