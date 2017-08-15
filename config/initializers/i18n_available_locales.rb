# frozen_string_literal: true

# Add additional locales to I18n's available locales
if ENV['I18N_ADDITIONAL_LOCALES']
  Rails.application.config.i18n.available_locales.tap do |available_locales|
    ENV['I18N_ADDITIONAL_LOCALES'].split(',').each do |locale|
      available_locales << locale.to_sym
    end

    available_locales.sort!

    counts = available_locales.each_with_object({}) do |locale, memo|
      memo[locale] = memo.key?(locale) ? memo[locale] + 1 : 1
    end

    duplicate_locales = counts.select { |_locale, count| count > 1 }

    if duplicate_locales.present?
      fail 'Duplicate locales detected: ' + duplicate_locales.keys.map(&:to_s).join(',')
    end
  end
end
