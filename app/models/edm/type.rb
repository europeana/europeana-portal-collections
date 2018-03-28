# frozen_string_literal: true

module EDM
  class Type < Base
    def label
      key = i18n.present? ? i18n : id.to_s.downcase
      I18n.t(key, scope: 'site.collections.data-types')
    end

    def icon
      super || id.to_s.downcase
    end
  end
end
