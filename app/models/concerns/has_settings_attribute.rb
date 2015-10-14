module HasSettingsAttribute
  extend ActiveSupport::Concern

  included do
    serialize :settings, HashWithIndifferentAccess
  end

  class_methods do
    # Dynamic accessor methods for serialized Hash(like) attributes
    def has_settings(*names)
      names.each do |meth|
        define_method("settings_#{meth}") do
          settings[meth.to_sym]
        end
        define_method("settings_#{meth}=") do |value|
          settings[meth.to_sym] = value
        end
      end
    end
  end
end
