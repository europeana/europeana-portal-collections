module RecordSettingsHash
  extend ActiveSupport::Concern

  class_methods do
    # Dynamic accessor methods for serialized Hash(like) attributes
    def has_record_settings_hash(attr, settings)
      serialize attr, HashWithIndifferentAccess

      settings.each do |meth|
        define_method("#{attr}_#{meth}") do
          self.send(attr.to_sym)[meth.to_sym]
        end
        define_method("#{attr}_#{meth}=") do |value|
          self.send(attr.to_sym)[meth.to_sym] = value
        end
      end
    end
  end
end
