# frozen_string_literal: true

require 'i18n_data'

module I18nData
  class << self
    alias_method :gem_normal_to_region_code, :normal_to_region_code

    def normal_to_region_code(normal)
      {
        'NO' => 'NB'
      }[normal] || gem_normal_to_region_code(normal)
    end
  end
end
